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

        /// Pull from a gacha pool
        /// Returns the owned item ids
        access(all)
        fun pullFromCachaPool(
            _ username: String,
            _ poolEntityId: UInt64,
            _ times: UInt64,
        ): [UInt64] {
            // Get the world
            let world = self.borrowWorld()

            // get gacha pool
            let poolComp = self.borrowGachaPoolComponent(poolEntityId)
            let boostingUpItems = poolComp.getBoostingProbabilityItems()

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

            // basic pool info
            var topRarity: UInt8 = 0
            var secRarity: UInt8 = 0
            let basicProb: {UInt8: UFix64} = {}
            let itemRarityDic: {UInt8: [UInt64]} = {}
            let boostingRarityDic: {UInt8: [UInt64]} = {}
            for itemId in allItems.keys {
                let item = allItems[itemId]!
                if topRarity < item.rarity {
                    secRarity = topRarity
                    topRarity = item.rarity
                }
                basicProb[item.rarity] = (basicProb[item.rarity] ?? 0.0) + poolComp.getProbabilityRatio(itemId)
                // check if item is boosting up item
                if boostingUpItems.contains(itemId) {
                    boostingRarityDic[item.rarity] = (boostingRarityDic[item.rarity] ?? []).concat([itemId])
                } else {
                    itemRarityDic[item.rarity] = (itemRarityDic[item.rarity] ?? []).concat([itemId])
                }
            }
            let boostingRatio = poolComp.getBoostingProbabilityRatio()

            // The return array
            let newOwnedItemIds: [UInt64] = []

            // --- calculate dynamic probability ---
            // last pulled info
            var currentCounter = playerComp.getGachaPoolCounter(poolEntityId)
            var currentRareCounter = playerComp.getGachaPoolRareCounter(poolEntityId)
            var lastPulledRareItem = playerComp.getGachaPoolLastPulledRare(poolEntityId)

            let sumProb: {UInt8: UFix64} = {}
            for rarity in basicProb.keys {
                basicProb[rarity] = basicProb[rarity]
            }
            // For every 10 pull, there is a basic guarantee
            // add probablity ratio for basic guarantee
            if currentCounter % 10 == 0 {
                sumProb[secRarity] = (sumProb[secRarity] ?? 0.0) + 1.0
            }
            // add probablity ratio for boosting up items
            let counterMod = poolComp.getProbabilityRatioModWithRareCounter(currentRareCounter)
            if counterMod != 0.0 {
                sumProb[topRarity] = (sumProb[topRarity] ?? 0.0) + counterMod
            }

            // sum of probability for rare items
            var totalProb: UFix64 = 0.0
            let probArr: [UFix64] = []
            let rarityIdxDic: {Int: UInt8} = {}
            // reverse order for rare probs
            var i: UInt8 = 10
            while i >= 0 {
                if let prob = sumProb[i] {
                    totalProb = totalProb + prob
                    probArr.append(prob)
                    rarityIdxDic[probArr.length - 1] = i
                }
                i = i - 1
            }

            // pull one item
            var rarityRand = self.geneRandomPercentage()
            var pickedRarity: UInt8? = nil
            for idx, prob in probArr {
                rarityRand = rarityRand.saturatingSubtract(prob)
                if rarityRand == 0.0 {
                    pickedRarity = rarityIdxDic[idx]
                    break
                }
            }

            // check boosting up items for rare items
            var itemsArrToPick: [UInt64] = itemRarityDic[pickedRarity!]!
            if pickedRarity == secRarity || pickedRarity == topRarity {
                // create a random number for picking item
                let rand = self.geneRandomPercentage()
                if rand < boostingRatio {
                    // Pick from boosting up items
                    itemsArrToPick = boostingRarityDic[pickedRarity!]!
                }
            }

            // pick from the item array
            let randIdx = self.geneRandomInRange(UInt64(itemsArrToPick.length))
            let pickedItemId = itemsArrToPick[randIdx]
            let pickedItemInfo = allItems[pickedItemId]!

            // add to Player's inventory
            let ownedId = inventorySystem.addItemToInventory(playerEntityId, pickedItemId, amount: pickedItemInfo.fungible ? 1.0 : nil)
            newOwnedItemIds.append(ownedId)

            // add counter to PlayerComponent
            playerComp.incrementGachaPoolCounter(poolEntityId, amount: 1)
            // set last pulled rare item
            if pickedRarity == topRarity {
                playerComp.setGachaPoolLastPulledRare(poolEntityId, pickedItemId)
            }

            return newOwnedItemIds
        }

        access(all)
        fun borrowGachaPoolComponent(_ poolEntityId: UInt64): &GachaPoolComponent.Component {
            let world = self.borrowWorld()
            let pool = world.borrowEntity(uid: poolEntityId) ?? panic("GachaPool not found")
            let poolComp = pool.borrowComponent(Type<@GachaPoolComponent.Component>()) as! &GachaPoolComponent.Component?
                ?? panic("GachaPoolComponent not found")
            return poolComp
        }

        /// --- Internal Methods ---

        access(self)
        fun geneRandomPercentage(): UFix64 {
            let rand = unsafeRandom()
            let randStr = "0.".concat(rand.toString().slice(from: 0, upTo: 5))
            return UFix64.fromString(randStr)!
        }

        access(self)
        fun geneRandomInRange(_ max: UInt64): UInt64 {
            let rand = unsafeRandom()
            return rand % max
        }

        // --- ISystem.CoreLifecycle ---

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
