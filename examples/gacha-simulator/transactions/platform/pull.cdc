import "CoreWorld"
import "GachaPlatform"
import "GachaPoolSystem"
import "GachaGameSystem"

/// Execute the pull from the gacha pool
/// This is called by the platform owner
transaction(
    userName: String,
    worldName: String,
    poolId: UInt64,
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
        // ensure pool exists
        let pool = gachaPoolSystem.borrowGachaPool(poolId)
        /// Pull items from the pool
        gachaGameSystem.pullFromCachaPool(userName, poolId, times)

        log("Pulled items from pool[".concat(pool.getName()).concat("] for user.").concat(userName))
    }
}
