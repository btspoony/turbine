// Third party imports
import "StringUtils"
// Turbine imports
import "IEntity"
import "IComponent"
import "IWorld"
import "Context"
import "EntityManager"

/// The contract interface of `System`.
/// A system is a container for all the logic that operates on entities that have a specific set of
/// components. Systems are the fundamental building blocks of a game's logic.
///
/// A system is a consumer of world context and is responsible for updating entities that have
/// specific components. Systems run continuously and are responsible for updating the state of
/// entities in the world.
///
pub contract interface ISystem {

    pub resource interface CoreLifecycle {
        /// Returns whether the system is enabled
        ///
        access(all) view
        fun getEnabled(): Bool

        /// Sets whether the system is enabled
        ///
        access(all) // TODO: Should now be `all` but that is not supported yet
        fun setEnabled(enabled: Bool): Void

        /// Called when the system is created
        ///
        access(all)
        fun onCreate(): Void {
            return
        }

        /// Called before the first call to OnUpdate and whenever a system resumes running.
        ///
        access(all)
        fun onStartRunning(): Void {
            pre {
                self.getEnabled(): "System must be enabled to start running"
            }
            return
        }

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            pre {
                self.getEnabled(): "System must be enabled to update"
            }
        }

        /// Called when the system is stopped either because the system is being destroyed or the
        /// system is no longer enabled.
        ///
        access(all)
        fun onStopRunning(): Void {
            pre {
                self.getEnabled(): "System must be enabled to stop running"
            }
            return
        }

        /// Called when the system is destroyed
        ///
        access(all)
        fun OnDestroy(): Void {
            return
        }
    }

    /// The system interface
    pub resource System: CoreLifecycle, Context.Consumer {
        access(contract)
        let worldCap: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        access(contract)
        var enabled: Bool

        /// Returns whether the system is enabled
        ///
        access(all) view
        fun getEnabled(): Bool {
            return self.enabled
        }

        /// Sets whether the system is enabled
        ///
        access(all)
        fun setEnabled(enabled: Bool) {
            self.enabled = enabled
        }

        /// Returns the storage path of the system
        ///
        access(all)
        fun getStoragePath(): StoragePath {
            let worldRef = self.borrowWorld()

            let identifier = self.getType().identifier
            let path = "Turbine_Systems_".concat(
                StringUtils.replaceAll(identifier, ".", "_")
            ).concat("_of_World_").concat(worldRef.getName())
             .concat("_").concat(worldRef.getAddress().toString())
            return StoragePath(identifier: path)!
        }

        /// The capability for the context provider.
        ///
        access(all)
        fun getProviderCapability(): Capability<&AnyResource{Context.Provider}> {
            return self.worldCap
        }

        /// The capability for the world state.
        ///
        access(all)
        fun borrowWorld(): &AnyResource{Context.Provider, IWorld.WorldState} {
            return self.worldCap.borrow()
                ?? panic("System has no world")
        }

        /// Returns the entity manager of the world
        ///
        access(all)
        fun getEntityManager(): &EntityManager.Manager {
            return self.borrowWorld().borrowEntityManager()
        }

        /// Returns the entity with the given id
        ///
        access(all)
        fun borrowEntity(_ entityId: UInt64): &IEntity.Entity {
            let world = self.borrowWorld()
            return world.borrowEntity(uid: entityId)
                ?? panic("Not Found, Entity:".concat(entityId.toString()))
        }
    }

    /// The system factory resource
    ///
    pub resource interface SystemFactory {
        /// Creates a new system
        ///
        pub fun create(
            world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ): @System

        /// Returns the type of the system
        ///
        pub fun instanceType(): Type
    }

    /// The create function for the system factory resource
    ///
    pub fun createFactory(): @{SystemFactory}
}
