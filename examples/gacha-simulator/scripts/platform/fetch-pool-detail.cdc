import "MetadataViews"
import "GachaPlatform"
import "GachaPoolComponent"
import "ItemComponent"
import "DisplayComponent"

pub fun main(
    worldName: String,
    poolId: UInt64
): [ItemData] {
    let addr = GachaPlatform.getContractAddress()
    let acct = getAuthAccount(addr)
    let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
        ?? panic("Cannot borrow platform from storage")

    let listedInfo = platform.getListedWorld(worldName) ?? panic("Cannot find world")
    let world = platform.borrowWorld(listedInfo.address, listedInfo.name)
    let entity = world.borrowEntity(uid: poolId) ?? panic("Cannot find pool: ".concat(poolId.toString()))
    let pool = entity.borrowComponent(Type<@GachaPoolComponent.Component>()) as! &GachaPoolComponent.Component?
        ?? panic("Cannot borrow pool component")
    let items = world.borrowEntities(uids: pool.getAllItems())

    // return items
    let ret: [ItemData] = []
    for itemId in items.keys {
        if let itemEntity = items[itemId]! {
            let item = itemEntity.borrowComponent(Type<@ItemComponent.Component>()) as! &ItemComponent.Component?
                ?? panic("Cannot borrow item component")
            let itemDisplay = itemEntity.borrowComponent(Type<@DisplayComponent.Component>()) as! &DisplayComponent.Component?
                ?? panic("Cannot borrow display component")
            ret.append(ItemData(
                item.toStruct(),
                itemDisplay.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display? ?? panic("Cannot resolve display")
            ))
        }
    }
    return ret
}

pub struct ItemData {
    pub let item: ItemComponent.ItemInfo
    pub let display: MetadataViews.Display
    init(_ item: ItemComponent.ItemInfo, _ display: MetadataViews.Display) {
        self.item = item
        self.display = display
    }
}

