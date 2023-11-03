import "MetadataViews"
import "CoreWorld"
import "GachaPlatform"
import "DisplayComponent"
import "ItemComponent"
import "OwnedItemComponent"
import "PlayerRegSystem"
import "InventorySystem"

pub fun main(
    worldName: String,
    ownedItemIds: [UInt64]
): [OwnedItemData] {
    let addr = GachaPlatform.getContractAddress()
    let acct = getAuthAccount(addr)
    let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
        ?? panic("Cannot borrow platform from storage")

    let listed = platform.getListedWorld(worldName) ?? panic("Cannot find listed world: ".concat(worldName))
    let worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
    let world = worldMgr.borrowWorld(worldName) ?? panic("Cannot borrow world: ".concat(worldName))

    // get inventory
    let inventorySystem = world.borrowSystem(Type<@InventorySystem.System>()) as! &InventorySystem.System

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
