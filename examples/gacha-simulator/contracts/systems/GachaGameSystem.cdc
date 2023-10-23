import "Context"
import "IWorld"
import "ISystem"
import "ItemComponent"
import "GachaPoolComponent"
import "InventoryComponent"
import "PlayerComponent"
import "InventorySystem"
import "PlayerRegSystem"

pub contract GachaGameSystem: ISystem {

    pub resource System: ISystem.CoreLifecycle, Context.Consumer {
        access(contract)
        let worldCap: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        access(contract)
        var enabled: Bool

        init(
            _ world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ) {
            self.worldCap = world
            self.enabled = true
        }

        access(all)
        fun pullFromCachaPool(
            _ username: String,
            _ poolEntityId: UInt64,
            _ times: UInt64,
        ): Void {
            // Get the world
            let world = self.borrowWorld()

            // get gacha pool
            let poolComp = self.borrowGachaPoolComponent(poolEntityId)
            let boostingUpItems = poolComp.getBoostingProbabilityItems()
            // let threshold = poolComp.getCounterThreshold()
            // let probMods = poolComp.getCounterProbabilityModifier()

            // get all Items' info
            let allItemIds = poolComp.getAllItems()
            let allItemEntities = world.borrowEntities(uids: allItemIds)
            let allItems: {UInt64: ItemComponent.ItemInfo} = {}
            for one in allItemEntities.keys {
                if let item = allItemEntities[one]! {
                    let comp = item.borrowComponent(Type<@ItemComponent.Component>()) ?? panic("ItemComponent not found")
                    allItems[one] = (comp as! &ItemComponent.Component).toStruct()
                }
            }

            // Get the player registration system
            let playerRegSystemCap = world.getSystemCapability(
                type: Type<@PlayerRegSystem.System>()
            ) as! Capability<auth &ISystem.System>
            let playerRegSystem = playerRegSystemCap.borrow() as! &PlayerRegSystem.System

            // Get the player entity
            let playerEntityId = playerRegSystem.fetchOrRegisterPlayer(username)
            let player = world.borrowEntity(uid: playerEntityId) ?? panic("Player not found")

            // get player's gacha record
            let playerComp = player.borrowComponent(Type<@PlayerComponent.Component>()) as! &PlayerComponent.Component?
                ?? panic("PlayerComponent not found")

            // Get the inventory system
            let inventorySystemCap = world.getSystemCapability(
                type: Type<@InventorySystem.System>()
            ) as! Capability<auth &ISystem.System>
            let inventorySystem = inventorySystemCap.borrow() as! &InventorySystem.System

            // last pulled info
            var currentCounter = playerComp.getGachaPoolCounter(poolEntityId)
            var lastPulledRareItem = playerComp.getGachaPoolLastPulledRare(poolEntityId)
            // sum of probability
            var sumProb: {UInt8: UFix64} = {}
            for itemId in allItems.keys {
                let item = allItems[itemId]!
                var prob: UFix64 = 0.0
                if boostingUpItems.contains(itemId) {
                    prob = poolComp.getProbabilityRatioWithCounter(itemId, currentCounter)
                } else {
                    prob = poolComp.getProbabilityRatio(itemId)
                }
                sumProb[item.rarity] = (sumProb[item.rarity] ?? 0.0) + prob
            }

            // sum of probability for rare items
            var totalProb: UFix64 = 0.0
            let rarityArr: [UFix64] = []
            let rarityDic: {Int: UInt8} = {}
            // reverse order for rare probs
            var i: UInt8 = 10
            while i >= 0 {
                if let prob = sumProb[i] {
                    totalProb = totalProb + prob
                    rarityArr.append(prob)
                    rarityDic[rarityArr.length - 1] = i
                }
                i = i - 1
            }

            // pull one item
            var rarityRand = self.geneRandomPercentage()
            var pickedRarity: UInt8? = nil
            for rarity, prob in rarityArr {
                rarityRand = rarityRand.saturatingSubtract(prob)
                if rarityRand == 0.0 {
                    pickedRarity = rarityDic[rarity]
                    break
                }
            }

            // TODO: pick from rarity pool
        }

        access(all)
        fun borrowGachaPoolComponent(_ poolEntityId: UInt64): &GachaPoolComponent.Component {
            let world = self.borrowWorld()
            let pool = world.borrowEntity(uid: poolEntityId) ?? panic("GachaPool not found")
            let poolComp = pool.borrowComponent(Type<@GachaPoolComponent.Component>()) as! &GachaPoolComponent.Component?
                ?? panic("GachaPoolComponent not found")
            return poolComp
        }

        access(self)
        fun geneRandomPercentage(): UFix64 {
            let rand = unsafeRandom()
            let randStr = "0.".concat(rand.toString().slice(from: 0, upTo: 5))
            return UFix64.fromString(randStr)!
        }

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // TODO: Add your system logic here
        }
    }

    /// The system factory resource
    ///
    pub resource SystemFactory: ISystem.SystemFactory {
        /// Creates a new system
        ///
        pub fun create(
            world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ): @System {
            return <- create System(world)
        }

        /// Returns the type of the system
        ///
        pub fun instanceType(): Type {
            return Type<@System>()
        }
    }

    /// The create function for the system factory resource
    ///
    pub fun createFactory(): @SystemFactory {
        return <- create SystemFactory()
    }
}
