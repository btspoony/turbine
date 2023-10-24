import "CoreWorld"
import "GachaModule"

pub contract GachaPlatform {

    // Paths
    pub let GachaPlatformStoragePath: StoragePath
    pub let GachaPlatformPublicPath: PublicPath

    // Events
    pub event WorldManagerDelegated(address: Address)

    pub event WorldPublished(address: Address, name: String, at: UFix64)
    pub event WorldUnpublished(address: Address, name: String, at: UFix64)

    pub event WorldCreated(host: Address, name: String)

    // Functions

    pub struct ListedWorld {
        pub let address: Address
        pub let name: String
        pub let listedAt: UFix64

        init(
            _ addr: Address,
            name: String,
            at: UFix64
        ) {
            self.address = addr
            self.name = name
            self.listedAt = at
        }
    }

    /// The platform resource interface
    ///
    pub resource interface PlatformPublic {
        // The listed worlds
        access(all)
        fun getListedWorlds(): [ListedWorld]

        /// Public a world to Dashboard
        access(all)
        fun publishWorld(_ worldMgrCap: Capability<&CoreWorld.WorldManager>, name: String)
    }

    /// The platform resource
    ///
    pub resource Platform: PlatformPublic {
        access(self)
        let listedWorlds: [ListedWorld]
        access(self)
        let delegatedManagers: {Address: Capability<&CoreWorld.WorldManager>}

        init() {
            self.listedWorlds = []
            self.delegatedManagers = {}
        }

        access(all)
        fun getListedWorlds(): [ListedWorld] {
            return self.listedWorlds
        }

        /// Public a world to Dashboard
        access(all)
        fun publishWorld(_ worldMgrCap: Capability<&CoreWorld.WorldManager>, name: String) {
            pre {
                worldMgrCap.check(): "WorldManager is not published"
            }
            let host = worldMgrCap.address
            if self.delegatedManagers[host] == nil {
                self.delegatedManagers[host] = worldMgrCap

                emit WorldManagerDelegated(address: host)
            }

            let worldMgr = worldMgrCap.borrow() ?? panic("WorldManager is not published")
            worldMgr.borrowWorld(name) ?? panic("World not found")

            let listed = ListedWorld(host, name: name, at: getCurrentBlock().timestamp)
            self.listedWorlds.append(listed)

            emit WorldPublished(address: host, name: listed.name, at: listed.listedAt)
        }

        access(all)
        fun unpublishWorld(host: Address, name: String) {
            let len = self.listedWorlds.length
            var i = 0
            while i < len {
                let listed = self.listedWorlds[i]
                if listed.address == host && listed.name == name {
                    self.listedWorlds.remove(at: i)
                    break
                }
                i = i + 1
            }
            emit WorldUnpublished(address: host, name: name, at: getCurrentBlock().timestamp)
        }

        /// Borrow the world manager
        ///
        access(all)
        fun borrowWorldManager(_ host: Address): &CoreWorld.WorldManager? {
            if let mgr = self.delegatedManagers[host] {
                return mgr.borrow()
            }
            return nil
        }

        /// Borrow the world
        ///
        access(all)
        fun borrowWorld(_ host: Address, _ name: String): &CoreWorld.World {
            let worldMgr = self.borrowWorldManager(host) ?? panic("WorldManager not found")
            return worldMgr.borrowWorld(name) ?? panic("World not found")
        }
    }

    /// Borrow the platform resource from storage
    ///
    access(all)
    fun borrowPlatform(): &Platform{PlatformPublic} {
        return getAccount(self.account.address)
            .capabilities
            .borrow<&Platform{PlatformPublic}>(self.GachaPlatformPublicPath)
            ?? panic("Could not borrow GachaPlatform from storage")
    }

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

        emit WorldCreated(host: acct.address, name: name)

        // Register the world to the platform
        let platformPubRef = GachaPlatform.borrowPlatform()
        let worldMgrCap = acct.capabilities.storage
            .issue<&CoreWorld.WorldManager>(CoreWorld.WorldManagerStoragePath)
        platformPubRef.publishWorld(worldMgrCap, name: name)
    }

    init() {
        let identifier = "GachaPlatform_".concat(self.account.address.toString())
        self.GachaPlatformStoragePath = StoragePath(identifier: identifier)!
        self.GachaPlatformPublicPath = PublicPath(identifier: identifier)!

        let platform <- create Platform()
        self.account.save(<- platform, to: self.GachaPlatformStoragePath)

        let pubCap = self.account.capabilities.storage
            .issue<&Platform{PlatformPublic}>(self.GachaPlatformStoragePath)
        self.account.capabilities.publish(pubCap, at: self.GachaPlatformPublicPath)
    }
}
