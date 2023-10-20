import "CoreWorld"

pub contract GachaPlatform {

    // Paths
    pub let GachaPlatformStoragePath: StoragePath
    pub let GachaPlatformPublicPath: PublicPath

    // Events

    pub event WorldPublished(address: Address, name: String, at: UFix64)
    pub event WorldUnpublished(address: Address, name: String, at: UFix64)

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
        /// Public a world to Dashboard
        access(all)
        fun publishWorld(_ worldMgr: &CoreWorld.WorldManager, name: String)
    }

    /// The platform resource
    ///
    pub resource Platform: PlatformPublic {
        pub let listedWorlds: [ListedWorld]

        init() {
            self.listedWorlds = []
        }

        /// Public a world to Dashboard
        access(all)
        fun publishWorld(_ worldMgr: &CoreWorld.WorldManager, name: String) {
            let host = worldMgr.owner?.address ?? panic("WorldManager is without owner")
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
