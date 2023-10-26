import "CoreWorld"
import "GachaPlatform"
import "ItemComponent"
import "OwnedItemComponent"
import "PlayerRegSystem"
import "InventorySystem"

pub fun main(
    worldName: String,
    username: String
): [ItemData] {
    let addr = GachaPlatform.getContractAddress()
    let acct = getAuthAccount(addr)
    let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
        ?? panic("Cannot borrow platform from storage")

    let listed = platform.getListedWorld(worldName) ?? panic("Cannot find listed world: ".concat(worldName))
    let worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
    let world = worldMgr.borrowWorld(worldName) ?? panic("Cannot borrow world: ".concat(worldName))

    // get player id
    let playerRegSystem = world.borrowSystem(Type<@PlayerRegSystem.System>()) as! &PlayerRegSystem.System
    let playerId = playerRegSystem.queryPlayerByUsername(username) ?? panic("Cannot find player: ".concat(username))

    // get inventory
    let inventorySystem = world.borrowSystem(Type<@InventorySystem.System>()) as! &InventorySystem.System
    let inventory = inventorySystem.borrowInventory(playerId)

    let ret: [ItemData] = []
    // get owned items
    let ownedItems = inventory.getOwnedItemIds()
    // get owned item component
    for id in ownedItems {
        let ownedItem = inventorySystem.borrowOwnedItem(id)
        let info = ownedItem.toStruct()
        let item = inventorySystem.borrowItem(info.itemEntityID)
        ret.append(ItemData(owned: info, item: item.toStruct()))
    }
    return ret
}

pub struct ItemData {
    pub let owned: OwnedItemComponent.OwnedItemInfo
    pub let item: ItemComponent.ItemInfo
    init (owned: OwnedItemComponent.OwnedItemInfo, item: ItemComponent.ItemInfo) {
        self.owned = owned
        self.item = item
    }
}
