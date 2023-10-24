import "CoreWorld"
import "GachaPlatform"

transaction(
    name: String,
) {
    let worldMgr: &CoreWorld.WorldManager
    let world: &CoreWorld.World

    prepare(acct: AuthAccount) {
        let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
            ?? panic("Cannot borrow platform from storage")

        let listed = platform.getListedWorld(name) ?? panic("Cannot find listed world")
        self.worldMgr = platform.borrowWorldManager(listed.address) ?? panic("Cannot borrow world manager")
        self.world = platform.borrowWorld(listed.address, name)
    }

    execute {
        // TODO

        log("World Synced")
    }
}
