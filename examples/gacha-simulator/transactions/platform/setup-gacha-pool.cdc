import "MetadataViews"
import "CoreWorld"
import "GachaPlatform"
import "ItemComponent"
import "ItemSystem"
import "GachaPoolSystem"
import "GachaPoolComponent"

/// Setup the gacha pool by Platform Account
/// This is called by the platform owner
transaction(
    worldName: String,
    poolName: String,
    rarityProbabilityPool: {UInt8: UFix64},
    counterThreshold: UInt64,
    counterProbabilityModifier: UFix64,
    boostingProbabilityRatio: UFix64,
    boostingProbabilityItems: [String],
    items: [{String: AnyStruct}],
) {
    let worldMgr: &CoreWorld.WorldManager
    let world: &CoreWorld.World

    prepare(acct: AuthAccount) {
        let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
            ?? panic("Cannot borrow platform from storage")

        let listed = platform.getListedWorld(worldName) ?? panic("Cannot find listed world")
        self.worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
        self.world = self.worldMgr.borrowWorld(worldName) ?? panic("Cannot borrow world")
    }

    execute {
        let gachaPoolSystem = self.world.borrowSystem(Type<@GachaPoolSystem.System>()) as! &GachaPoolSystem.System
        let itemSystem = self.world.borrowSystem(Type<@ItemSystem.System>()) as! &ItemSystem.System

        // --- Add items to item system ---
        let addedItemIds: [UInt64] = []
        let boostingItemIds: [UInt64] = []
        for data in items {
            log("Item: name="
                .concat(data["name"] as! String? ?? "no name")
                .concat(", description=")
                .concat(data["description"] as! String? ?? "no description")
                .concat(", thumbnail=")
                .concat(data["thumbnail"] as! String? ?? "no thumbnail")
                .concat(", rarity=")
                .concat((data["rarity"] as! UInt8? ?? 0).toString())
                .concat(", category=")
                .concat((data["category"] as! UInt8? ?? 0).toString())
                .concat(", identity=")
                .concat(data["identity"] as! String? ?? "no identity")
            )
            assert(
                data.containsKey("name") && data.containsKey("description") && data.containsKey("thumbnail") &&
                data.containsKey("rarity") && data.containsKey("category") && data.containsKey("identity"),
                message: "Item's data must contain name, discription, thumbnail, rarity, category, identity"
            )
            let itemIdentity = data["identity"] as! String? ?? panic("Invalid identity")
            let itemInfo = ItemComponent.ItemInfo(
                ItemComponent.ItemCategory(rawValue: data["category"] as! UInt8? ?? panic("Invalid category")) ?? panic("Invalid category"), // category: ItemComponent.ItemCategory,
                false, // _ fungible: Bool,
                itemIdentity, // _ identity: String,
                data["rarity"] as! UInt8? ?? panic("Invalid rarity"), // _ rarity: UInt8,
                {} // _ traits: {String: UInt8}
            )
            let display = MetadataViews.Display(
                name: (data["name"] as! String?) ?? panic("Invalid name"), // _ name: String,
                description: (data["description"] as! String?) ?? panic("Invalid description"), // _ description: String
                thumbnail: MetadataViews.HTTPFile(
                    url: data["thumbnail"] as! String? ?? panic("Invalid thumbnail"), // _ url: String,
                )
            )
            // add item to item system
            let id = itemSystem.addItemEntity(itemInfo: itemInfo, display: display)
            addedItemIds.append(id)
            if boostingProbabilityItems.contains(itemIdentity) {
                boostingItemIds.append(id)
            }
        }

        // --- create a new gacha pool ---
        let poolId = gachaPoolSystem.createNewGachaPoolEntity(poolName)

        // --- Add items to gacha pool ---
        gachaPoolSystem.setRareProbabilityPool(poolId, rarityProbabilityPool)
        gachaPoolSystem.addItemsToPool(poolId, itemEntityIds: addedItemIds)
        gachaPoolSystem.setGachaCounter(poolId, threshold: counterThreshold, probabilityMod: counterProbabilityModifier)
        gachaPoolSystem.setBoostingProbabilityItems(poolId, itemEntities: boostingItemIds, probability: boostingProbabilityRatio)
        gachaPoolSystem.setEnabled(enabled: true)

        log("Complete setup gacha pool")
    }
}
