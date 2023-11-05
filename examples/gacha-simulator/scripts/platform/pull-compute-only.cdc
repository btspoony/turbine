import "MetadataViews"
import "CoreWorld"
import "GachaPlatform"
import "GachaPoolSystem"
import "GachaGameSystem"
import "InventorySystem"
import "ItemComponent"
import "OwnedItemComponent"
import "DisplayComponent"

pub fun main(
    userName: String,
    worldName: String,
    poolId: UInt64,
    times: UInt64
): [OwnedItemData] {
    let addr = GachaPlatform.getContractAddress()
    let acct = getAuthAccount(addr)
    let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
        ?? panic("Cannot borrow platform from storage")

    let listed = platform.getListedWorld(worldName) ?? panic("Cannot find listed world: ".concat(worldName))
    let worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
    let world = worldMgr.borrowWorld(worldName) ?? panic("Cannot borrow world: ".concat(worldName))

    let gachaPoolSystem = world.borrowSystem(Type<@GachaPoolSystem.System>()) as! &GachaPoolSystem.System
    let gachaGameSystem = world.borrowSystem(Type<@GachaGameSystem.System>()) as! &GachaGameSystem.System
    let inventorySystem = world.borrowSystem(Type<@InventorySystem.System>()) as! &InventorySystem.System

    // ensure pool exists
    let pool = gachaPoolSystem.borrowGachaPool(poolId)
    /// Pull items from the pool
    let ownedItemIds = gachaGameSystem.pullFromCachaPool(userName, poolId, times)
    log("Pulled items from pool[".concat(pool.getName()).concat("] for user.").concat(userName))

    let ret: [OwnedItemData] = []
    // get owned item component
    for id in ownedItemIds {
        // owned item info
        let ownedItem = inventorySystem.borrowOwnedItem(id)
        let ownedInfo = ownedItem.toStruct()

        // fetch item entity
        let itemEntity = world.borrowEntity(uid: ownedInfo.itemEntityID) ?? panic("Cannot find item entity")
        // get item component
        var comp = itemEntity.borrowComponent(Type<@ItemComponent.Component>())
            ?? panic("Failed to borrow item component")
        let item = comp as! &ItemComponent.Component
        let itemInfo = item.toStruct()
        // get display component
        comp = itemEntity.borrowComponent(Type<@DisplayComponent.Component>())
            ?? panic("Failed to borrow display component")
        let itemDisplay = comp as! &DisplayComponent.Component

        // append to result
        ret.append(OwnedItemData(
            id: id,
            owned: ownedItem.toStruct(),
            item: itemInfo,
            display: itemDisplay.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display? ?? panic("Cannot resolve display")
        ))
        log("Appended Item: ".concat(id.toString()).concat(" - ").concat(itemInfo.identity))
    }

    return ret
}

pub struct OwnedItemData {
    pub let id: UInt64
    pub let owned: OwnedItemComponent.OwnedItemInfo
    pub let item: ItemComponent.ItemInfo
    pub let display: MetadataViews.Display

    init (
        id: UInt64,
        owned: OwnedItemComponent.OwnedItemInfo,
        item: ItemComponent.ItemInfo,
        display: MetadataViews.Display
    ) {
        self.id = id
        self.owned = owned
        self.item = item
        self.display = display
    }
}
