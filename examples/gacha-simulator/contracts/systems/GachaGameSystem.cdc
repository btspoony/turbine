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

    // --- Events ---

    pub event PlayerPulled(
        _ username: String,
        _ poolEntityId: UInt64,
        _ times: UInt64,
        _ ownedItemIds: [UInt64],
    )

    // --- System ---

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
            let playerRegSystem = playerRegSystemCap.borrow() as! &PlayerRegSystem.System? ?? panic("PlayerRegSystem not found")

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
            let inventorySystem = inventorySystemCap.borrow() as! &InventorySystem.System? ?? panic("InventorySystem not found")

            // basic pool info
            var topRarity: UInt8 = 0
            var secRarity: UInt8 = 0
            var btnRarity: UInt8 = UInt8.max
            let basicProb: {UInt8: UFix64} = poolComp.getRarityProbabilityPool()
            let itemRarityDic: {UInt8: [UInt64]} = {}
            let boostingRarityDic: {UInt8: [UInt64]} = {}
            // set probability for each rarity
            for itemId in allItems.keys {
                let item = allItems[itemId]!
                if topRarity < item.rarity {
                    topRarity = item.rarity
                }
                if secRarity < item.rarity && item.rarity < topRarity {
                    secRarity = item.rarity
                }
                if btnRarity > item.rarity {
                    btnRarity = item.rarity
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

            log("DEBUG: topRarity: ".concat(topRarity.toString())
                .concat(" secRarity: ").concat(secRarity.toString())
                .concat(" btnRarity: ").concat(btnRarity.toString())
                .concat(" counterThreshold: ").concat(poolComp.getCounterThreshold().toString())
                .concat(" boostingRatio: ").concat(boostingRatio.toString()))

            // The return array
            let newOwnedItemIds: [UInt64] = []

            // --- calculate dynamic probability ---
            var pullCnt: UInt64 = 0
            // Now Pull for one item for free
            while pullCnt < times {
                let counterStr = "DEBUG: Pulling ".concat((pullCnt+1).toString()).concat("/").concat(times.toString()).concat(": ")

                // last pulled info
                var currentCounter = playerComp.getGachaPoolCounter(poolEntityId)
                var currentRareCounter = playerComp.getGachaPoolRareCounter(poolEntityId)
                var lastPulledRareItem = playerComp.getGachaPoolLastPulledRare(poolEntityId)

                log(counterStr.concat("Current TotalCtr: ").concat(currentCounter.toString())
                    .concat(" Current RareCtr: ").concat(currentRareCounter.toString()))

                let sumProb: {UInt8: UFix64} = {}
                for rarity in basicProb.keys {
                    sumProb[rarity] = basicProb[rarity]
                }
                // For every 10 pull, there is a basic guarantee
                // add probablity ratio for basic guarantee
                if currentCounter % 10 == 9 {
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
                var i: UInt8 = topRarity
                while i >= btnRarity {
                    if let prob = sumProb[i] {
                        totalProb = totalProb + prob
                        probArr.append(prob)
                        // random index for rarity
                        let idx = probArr.length - 1
                        rarityIdxDic[idx] = i
                        log(counterStr.concat("[").concat(idx.toString()).concat("] Rarity<".concat(i.toString()).concat("> Prob = ")
                            .concat(prob.toString())))
                    }
                    i = i.saturatingSubtract(1)
                }

                // pull one item
                let rarityRand = self.geneRandomPercentage()
                var pickedRarity: UInt8 = btnRarity
                var currRandAmt = rarityRand
                for idx, prob in probArr {
                    currRandAmt = currRandAmt.saturatingSubtract(prob)
                    if currRandAmt == 0.0 {
                        pickedRarity = rarityIdxDic[idx]!
                        break
                    }
                }
                log(counterStr.concat("Pull rarityRand: ").concat(rarityRand.toString())
                    .concat(" Picked Rarity: ").concat(pickedRarity.toString()))

                // check boosting up items for rare items
                var itemsArrToPick: [UInt64] = itemRarityDic[pickedRarity]!
                if pickedRarity == secRarity || pickedRarity == topRarity {
                    // create a random number for picking item
                    let rand = self.geneRandomPercentage()
                    // if rand < boostingRatio or last pulled item is not boosting up item
                    // then pick from boosting up items
                    if rand < boostingRatio || (pickedRarity == topRarity && lastPulledRareItem != nil && !boostingUpItems.contains(lastPulledRareItem!)) {
                        // Pick from boosting up items
                        itemsArrToPick = boostingRarityDic[pickedRarity]!
                    }
                }

                // pick from the item array
                let randIdx = self.geneRandomInRange(UInt64(itemsArrToPick.length))
                let pickedItemId = itemsArrToPick[randIdx]
                let pickedItemInfo = allItems[pickedItemId]!

                // add to Player's inventory
                let ownedId = inventorySystem.addItemToInventory(playerEntityId, pickedItemId, amount: pickedItemInfo.fungible ? 1.0 : nil)
                newOwnedItemIds.append(ownedId)

                log(counterStr.concat("Picked Item: ").concat(pickedItemInfo.identity)
                    .concat(", Created Owned Item: ").concat(ownedId.toString()))

                // add counter to PlayerComponent
                playerComp.incrementGachaPoolCounter(poolEntityId, amount: 1)
                // set last pulled rare item
                if pickedRarity == topRarity {
                    playerComp.setGachaPoolLastPulledRare(poolEntityId, pickedItemId)
                }

                // increment pull counter
                pullCnt = pullCnt.saturatingAdd(1)
            }

            emit PlayerPulled(username, poolEntityId, times, newOwnedItemIds)

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
            var randStr = revertibleRandom().toString()
            if randStr.length < 5 {
                randStr = "00000".concat(randStr)
            }
            let lastFiveStr = randStr.slice(from: randStr.length - 5, upTo: randStr.length)
            return UFix64.fromString("0.".concat(lastFiveStr))!
        }

        access(self)
        fun geneRandomInRange(_ max: UInt64): UInt64 {
            let rand = revertibleRandom()
            return rand % max
        }

        // --- ISystem.CoreLifecycle ---

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // NOTHING
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
