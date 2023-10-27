import "CoreWorld"
import "GachaPlatform"
import "ItemComponent"
import "OwnedItemComponent"
import "PlayerRegSystem"
import "InventorySystem"

pub fun main(
    worldName: String,
    username: String
): [OwnedItemData] {
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

    log("---------- Inventory of ".concat(username).concat(" ----------"))
    let counterDic: {String: UInt64} = {}
    let logStrDic: {String: String} = {}

    let ret: [OwnedItemData] = []
    // get owned items
    let ownedItems = inventory.getOwnedItemIds()
    // get owned item component
    for id in ownedItems {
        let ownedItem = inventorySystem.borrowOwnedItem(id)
        let ownedInfo = ownedItem.toStruct()
        let item = inventorySystem.borrowItem(ownedInfo.itemEntityID)
        let itemInfo = item.toStruct()

        ret.append(OwnedItemData(owned: ownedInfo, item: itemInfo))

        counterDic[itemInfo.identity] = (counterDic[itemInfo.identity] ?? 0) + 1
        if logStrDic[itemInfo.identity] == nil {
            logStrDic[itemInfo.identity] = "Item: ".concat(itemInfo.identity)
                .concat(" Type: ").concat(itemInfo.category == ItemComponent.ItemCategory.Weapon ? "Weapon" : "Character")
                .concat(" Rarity: ").concat(itemInfo.rarity.toString())
        }
    }

    for key in logStrDic.keys {
        log(key.concat(" x ").concat(counterDic[key]!.toString()))
    }
    return ret
}

pub struct OwnedItemData {
    pub let owned: OwnedItemComponent.OwnedItemInfo
    pub let item: ItemComponent.ItemInfo
    init (owned: OwnedItemComponent.OwnedItemInfo, item: ItemComponent.ItemInfo) {
        self.owned = owned
        self.item = item
    }
}
