import "EntityQuery"
import "GachaPlatform"
import "GachaPoolComponent"

pub fun main(): [GachaPool] {
    let addr = GachaPlatform.getContractAddress()
    let acct = getAuthAccount(addr)
    let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
        ?? panic("Cannot borrow platform from storage")

    let listedWorlds = platform.getListedWorlds()
    let gachaPoolType = Type<@GachaPoolComponent.Component>()
    let query = EntityQuery.Builder()
    query.withAll(types: [gachaPoolType])

    let ret: [GachaPool] =[]
    for info in listedWorlds {
        let world = platform.borrowWorld(info.address, info.name)
        let entities = query.executeQuery(world)
        for entity in entities {
            if let pool = entity.borrowComponent(gachaPoolType) as! &GachaPoolComponent.Component? {
                ret.append(GachaPool(
                    host: info.address,
                    world: info.name,
                    poolId: entity.getId(),
                    poolName: pool.getName()
                ))
            }
        }
    }
    return ret
}

pub struct GachaPool {
    pub let host: Address
    pub let world: String
    pub let poolId: UInt64
    pub let poolName: String

    init (
        host: Address,
        world: String,
        poolId: UInt64,
        poolName: String
    ) {
        self.host = host
        self.world = world
        self.poolId = poolId
        self.poolName = poolName
    }
}
