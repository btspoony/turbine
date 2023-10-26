import "CoreWorld"
import "GachaPlatform"
import "GachaPoolSystem"
import "GachaGameSystem"

/// Execute the pull from the gacha pool
/// This is called by the platform owner
transaction(
    userName: String,
    worldName: String,
    poolName: String,
    times: UInt64
) {
    let worldMgr: &CoreWorld.WorldManager
    let world: &CoreWorld.World

    prepare(acct: AuthAccount) {
        let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
            ?? panic("Cannot borrow platform from storage")

        let listed = platform.getListedWorld(worldName) ?? panic("Cannot find listed world: ".concat(worldName))
        self.worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
        self.world = self.worldMgr.borrowWorld(worldName) ?? panic("Cannot borrow world: ".concat(worldName))
    }

    pre {
        times <= 10: "Cannot pull more than 10 times"
    }

    execute {
        let gachaPoolSystem = self.world.borrowSystem(Type<@GachaPoolSystem.System>()) as! &GachaPoolSystem.System
        let gachaGameSystem = self.world.borrowSystem(Type<@GachaGameSystem.System>()) as! &GachaGameSystem.System

        let pool = gachaPoolSystem.findGachaPoolEntity(name: poolName) ?? panic("Cannot find gacha pool: ".concat(poolName))
        /// Pull items from the pool
        gachaGameSystem.pullFromCachaPool(userName, pool.getId(), times)

        log("Pulled items from pool[".concat(poolName).concat("] for user.").concat(userName))
    }
}
