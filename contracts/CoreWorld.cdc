import "IEntity"
import "IComponent"
import "IWorld"
import "ISystem"
import "Context"
import "EntityManager"
import "EntityQuery"
import "CoreEntity"

pub contract CoreWorld: IWorld {

    // --- Paths ---
    pub let WorldManagerStoragePath: StoragePath
    pub let WorldManagerPublicPath: PublicPath

    // --- Events ---
    pub event WorldManagerCreated(address: Address)
    pub event SystemFactoryRegistered(address: Address, system: Type)

    pub event SystemAdded(address: Address, name: String, system: Type)
    pub event SystemEnabledUpdate(address: Address, name: String, system: Type, enabled: Bool)
    pub event SystemRemoved(address: Address, name: String, system: Type)

    pub event WorldCreated(address: Address, name: String)
    pub event WorldUpdated(address: Address, name: String, dt: UFix64)

    /// The context of the world
    ///
    pub resource World: IWorld.WorldState, Context.Provider {
        // --- Fields From interface ---
        access(contract)
        let entities: @{UInt64: IEntity.Entity}
        // --- Fields ---
        /// The name of the world.
        access(self)
        let name: String
        /// The entity manager.
        access(self)
        let entityManager: @EntityManager.Manager
        /// The current time of the world.
        access(self)
        var currentTime: UFix64
        /// The collection of systems that the world supports.
        access(self)
        let systems: {Type: Capability<&ISystem.System>}
        /// The changes of systems' enabled status.
        access(self)
        var systemsEnabledStatusChanged: {Type: Bool}

        init(
            _ name: String
        ) {
            self.name = name
            self.entities <- {}
            self.entityManager <- EntityManager.create(factory: <- CoreEntity.createFactory())
            self.currentTime = getCurrentBlock().timestamp
            self.systems = {}
            self.systemsEnabledStatusChanged = {}
        }

        destroy() {
            destroy self.entities
            destroy self.entityManager
        }

        // --- General ---

        /// The name of the wrold.
        ///
        access(all)
        fun getName(): String {
            return self.name
        }

        /// Returns the current time of the world.
        ///
        access(all)
        fun getCurrentTime(): UFix64 {
            return self.currentTime
        }

        // --- Entity Related ---

        /// Fetch the entity manager
        ///
        access(all)
        fun borrowEntityManager(): &EntityManager.Manager {
            return &self.entityManager as &EntityManager.Manager
        }

        // --- System Related ---

        /// The list of system types that the context provider supports.
        ///
        access(all)
        fun getSystemTypes(): [Type] {
            return self.systems.keys
        }

        /// Fetches the system capability for the given type.
        ///
        access(all)
        fun getSystemCapability(type: Type): Capability<&ISystem.System> {
            return self.systems[type] ?? panic("System not found")
        }

        /// Adds a system to the context provider.
        ///
        access(all)
        fun addSystem(system: Capability<&ISystem.System>) {
            pre {
                system.check(): "Invalid system capability"
            }
            let systemRef = system.borrow() ?? panic("System not found")
            let insType = systemRef.getType()
            assert(self.systems[insType] == nil, message: "System already exists")

            self.systems[insType] = system
            systemRef.setEnabled(enabled: true)
            self.systemsEnabledStatusChanged[insType] = true
            // call system onCreate
            systemRef.onCreate()

            emit SystemAdded(address: self.getAddress(), name: self.getName(), system: insType)
        }

        /// Sets the enabled status of a system.
        ///
        access(all)
        fun setSystemEnabled(system: Type, enabled: Bool) {
            pre {
                self.systems[system] != nil: "System not found"
            }
            let systemRef = self.borrowSystem(system)
            if systemRef.getEnabled() != enabled {
                systemRef.setEnabled(enabled: enabled)

                self.systemsEnabledStatusChanged[system] = true

                emit SystemEnabledUpdate(address: self.getAddress(), name: self.getName(), system: system, enabled: enabled)
            }
        }

        /// Mark as removed, remove a system from the context provider.
        ///
        access(all)
        fun removeSystem(system: Type) {
            pre {
                self.systems[system] != nil: "System not found"
            }
            let systemRef = self.borrowSystem(system)
            self.systems.remove(key: system)

            // call system onDestroy
            systemRef.onStopRunning()
            systemRef.OnDestroy()

            emit SystemRemoved(address: self.getAddress(), name: self.getName(), system: system)
        }

        // --- World Lifecycle Methods ---

        /// The world update method.
        ///
        access(all)
        fun update(_ dt: UFix64): Void {
            let toStop: [Type] = []
            // Before update
            for t in self.systemsEnabledStatusChanged.keys {
                let ref = self.borrowSystem(t)
                let changed = self.systemsEnabledStatusChanged[t]!
                if !changed { continue }
                let enabled = ref.getEnabled()
                if enabled {
                    // call system onStartRunning
                    ref.onStartRunning()
                } else {
                    toStop.append(t)
                }
            }

            // call system onUpdate
            for t in self.systems.keys {
                let systemRef = self.borrowSystem(t)
                let enabled = systemRef.getEnabled()
                if !enabled { continue }
                systemRef.onUpdate(dt)
            }

            // After update
            // call system onStopRunning
            let toStopLen = toStop.length
            var i = 0
            while i < toStopLen {
                let t = toStop[i]
                let ref = self.borrowSystem(t)
                ref.onStopRunning()
                i = i + 1
            }
            // reset the changes
            self.systemsEnabledStatusChanged = {}

            emit WorldUpdated(address: self.getAddress(), name: self.getName(), dt: dt)
        }

        // --- Internal Methods ---

        /// Fetch the address of the world
        ///
        access(self)
        fun borrowSystem(_ type: Type): &ISystem.System {
            pre {
                self.systems[type] != nil: "System not found"
            }
            return self.systems[type]!.borrow() ?? panic("System not found")
        }
    }

    /// The world manager is responsible for creating and managing worlds.
    ///
    pub resource WorldManager: IWorld.WorldManagerPublic, IWorld.WorldManagerAdmin, IWorld.WorldExecutor {
        /// Capability on the underlying account object
        access(self) let acct: Capability<&AuthAccount>
        access(self) let factories: @{Type: AnyResource{ISystem.SystemFactory}}
        access(self) let worlds: {String: Capability<&World>}

        init(
            _ owner: Capability<&AuthAccount>
        ) {
            self.acct = owner
            self.factories <- {}
            self.worlds = {}
        }

        destroy() {
            destroy self.factories
        }

        // --- Public Methods ---

        /// Fetch the world storage path by name
        ///
        access(all)
        fun getWorldStoragePath(_ name: String): StoragePath {
            let identifier = CoreWorld.getWorldResourceIdentifier(name)
            return StoragePath(identifier: name)!
        }

        /// Fetch the world public path by name
        ///
        access(all)
        fun getWorldPublicPath(_ name: String): PublicPath {
            let identifier = CoreWorld.getWorldResourceIdentifier(name)
            return PublicPath(identifier: name)!
        }

        // --- World Methods ---

        /// Create a new world
        ///
        access(all)
        fun create(_ name: String, withSystems: [Type]): &World {
            let acct = self.borrowAuthAccount()

            let world <- create World(name)
            let identifier = CoreWorld.getWorldResourceIdentifier(name)
            let storagePath = StoragePath(identifier: identifier)!

            // save the world resource
            acct.save(<- world, to: storagePath)

            // store the world public capability
            let privCap = acct.capabilities.storage.issue<&World>(storagePath)
            assert(privCap.check(), message: "Failed to create private capability")
            self.worlds[name] = privCap

            // add systems
            let worldRef = acct.borrow<&World>(from: storagePath) ?? panic("World not found")
            for system in withSystems {
                self.addSystem(to: name, system: system)
            }

            emit WorldCreated(address: acct.address, name: name)

            // return the world reference
            return worldRef
        }

        /// Borrow the world by name
        ///
        access(all)
        fun borrowWorld(_ name: String): &World? {
            if let worldCap = self.worlds[name] {
                return self.worlds[name]!.borrow()
            }
            return nil
        }

        /// Fetch the world capability by name
        ///
        access(all)
        fun buildWorldCapability(_ name: String): Capability<&World> {
            pre {
                self.worlds[name] != nil: "World not found"
            }
            post {
                result.check(): "Invalid world capability"
            }
            let acct = self.borrowAuthAccount()
            let identifier = CoreWorld.getWorldResourceIdentifier(name)
            let storagePath = StoragePath(identifier: identifier)!
            return acct.capabilities.storage.issue<&World>(storagePath)
        }

        /// Iterate all worlds
        ///
        access(all)
        fun forEachWorlds(_ callback: ((String, &IWorld.World): Void)) {
            for key in self.worlds.keys {
                if let world = self.worlds[key]!.borrow() {
                    callback(key, world)
                }
            }
        }

        // --- World Executor Methods ---

        /// Fetch the world current time
        ///
        access(all) view
        fun getWorldCurrentTime(_ name: String): UFix64 {
            let world = self.borrowWorld(name) ?? panic("World not found")
            return world.getCurrentTime()
        }

        /// Update the world
        ///
        access(all)
        fun updateWorld(_ name: String, now: UFix64): Void {
            let world = self.borrowWorld(name) ?? panic("World not found")
            let currentTime = world.getCurrentTime()
            world.update(now - currentTime)
        }

        /// Update all worlds
        ///
        access(all)
        fun updateAllWorlds(now: UFix64): Void {
            self.forEachWorlds(fun (name: String, world: &IWorld.World): Void {
                let currentTime = world.getCurrentTime()
                world.update(now - currentTime)
            })
        }

        // --- System Methods ---

        /// Add a system to the world
        ///
        access(all)
        fun addSystem(to: String, system: Type): Void {
            let acct = self.borrowAuthAccount()
            let factory = self.borrowSystemFactory(system)

            // Ensure the world exists
            let world = self.borrowWorld(to) ?? panic("World not found")

            // Ensure the system doesn't already exist
            assert(world.getSystemTypes().contains(system) == false, message: "System already exists")

            let systemIns <- factory.create(world: self.buildWorldCapability(to))
            let systemStoragePath = systemIns.getStoragePath()
            // Ensure the system storage path is not already in use
            assert(acct.borrow<&AnyResource>(from: systemStoragePath) == nil, message: "System storage path already in use")

            // Store the system resource
            acct.save(<- systemIns, to: systemStoragePath)

            // Add the system to the world
            let systemCap = acct.capabilities.storage.issue<&ISystem.System>(systemStoragePath)
            assert(systemCap.check(), message: "Failed to create system capability")

            world.addSystem(system: systemCap)
        }

        /// Set enabled status of a system
        ///
        access(all)
        fun setSystemEnabled(to: String, system: Type, enabled: Bool): Void {
            // Ensure the world exists
            let world = self.borrowWorld(to) ?? panic("World not found")

            // Ensure the system exists
            assert(world.getSystemTypes().contains(system) == true, message: "System not found")

            // Set the enabled status
            world.setSystemEnabled(system: system, enabled: enabled)
        }

        /// Remove a system from the world
        ///
        access(all)
        fun removeSystem(from: String, system: Type): Void {
            let acct = self.borrowAuthAccount()

            // Ensure the world exists
            let world = self.borrowWorld(from) ?? panic("World not found")

            // Ensure the system exists
            let systemCap = world.getSystemCapability(type: system)
            let systemRef = systemCap.borrow() ?? panic("System not found")

            // Remove the system from the world
            world.removeSystem(system: system)

            // Remove the system resource
            destroy acct.load<@ISystem.System>(from: systemRef.getStoragePath())
        }

        // --- System Admin Methods ---

        /// Register a system factory
        ///
        access(all)
        fun registerSystemFactory(factory: @AnyResource{ISystem.SystemFactory}): Void {
            let systemType = factory.instanceType()
            assert(self.factories[systemType] == nil, message: "System factory already registered")

            self.factories[systemType] <-! factory

            emit SystemFactoryRegistered(address: self.acct.address, system: systemType)
        }

        // --- Internal Methods ---

        /// Borrow the underlying account object
        ///
        access(self)
        fun borrowAuthAccount(): &AuthAccount {
            pre {
                self.acct.address == self.owner?.address: "Only the owner can call this method"
            }
            return self.acct.borrow() ?? panic("AuthAccount not found")
        }

        /// Borrow a system factory
        ///
        access(self)
        fun borrowSystemFactory(_ system: Type): &AnyResource{ISystem.SystemFactory} {
            pre {
                self.factories[system] != nil: "System factory not found: ".concat(system.identifier)
            }
            return (&self.factories[system] as &AnyResource{ISystem.SystemFactory}?)!
        }
    }

    /// The identifier for the world resource
    ///
    access(contract)
    fun getWorldResourceIdentifier(_ name: String): String {
        return "TurbineEngineWorld_"
            .concat(self.account.address.toString())
            .concat("_")
            .concat(name)
    }

    /// The world create method
    ///
    pub fun createManager(
        admin: Capability<&AuthAccount>
    ): &WorldManager {
        let acct = admin.borrow() ?? panic("AuthAccount not found")
        let worldMgr <- create WorldManager(admin)

        acct.save(<- worldMgr, to: self.WorldManagerStoragePath)
        emit WorldManagerCreated(address: acct.address)

        // publish the world manager capability
        let pubCap = acct.capabilities.storage
            .issue<&WorldManager{IWorld.WorldManagerPublic}>(self.WorldManagerStoragePath)
        acct.capabilities.publish(pubCap, at: self.WorldManagerPublicPath)

        // return the world manager reference
        return acct.borrow<&WorldManager>(from: self.WorldManagerStoragePath)
            ?? panic("WorldManager not found")
    }

    init() {
        let identifier = "TurbineEngineWorldManager_".concat(self.account.address.toString())
        self.WorldManagerStoragePath = StoragePath(identifier: identifier)!
        self.WorldManagerPublicPath = PublicPath(identifier: identifier)!
    }
}
