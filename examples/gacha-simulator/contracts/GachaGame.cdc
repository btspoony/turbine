import "CoreWorld"
import "GachaModule"
import "GachaPlatform"

pub contract GachaGame {

    pub event GachaWorldCreated(host: Address, name: String)

    /// Create a new game world
    access(all)
    fun createGachaWorld(
        _ admin: Capability<&AuthAccount>,
        name: String
    ) {
        // Borrow the admin account
        let acct = admin.borrow() ?? panic("Could not borrow admin account")
        // Fetch or create the world manager
        var worldMgr: &CoreWorld.WorldManager? = nil
        if !CoreWorld.hasManager(acct: acct.address) {
            worldMgr = CoreWorld.createManager(admin: admin)
        } else {
            worldMgr = acct.borrow<&CoreWorld.WorldManager>(from: CoreWorld.WorldManagerStoragePath)
        }
        assert(worldMgr != nil, message: "Could not borrow world manager")

        // Create the world
        let world = worldMgr!.create(name, withSystems: [])
        // Load modules to the world
        worldMgr!.installModule(to: name, <- GachaModule.createModule())

        // Register the world to the platform
        let platformPubRef = GachaPlatform.borrowPlatform()
        let worldMgrCap = acct.capabilities.storage
            .issue<&CoreWorld.WorldManager>(CoreWorld.WorldManagerStoragePath)
        platformPubRef.publishWorld(worldMgrCap, name: name)

        emit GachaWorldCreated(host: acct.address, name: name)
    }
}
