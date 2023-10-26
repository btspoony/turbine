import "IEntity"
import "Context"
import "EntityManager"
import "EntityQuery"

/// The world is the root of the object graph. It contains all the entities in the game.
/// It is also responsible for managing entities.
pub contract interface IWorld {

    pub resource interface WorldState {
        /// The name of the wrold.
        ///
        access(all)
        fun getName(): String

        /// The address of the wrold.
        ///
        access(all)
        fun getAddress(): Address

        // --- Module Methods ---

        /// Fetch the installed modules' names.
        ///
        access(all)
        fun getInstalledModules(): [String]

        // --- System Methods ---

        /// The list of system types that the context provider supports.
        ///
        access(all)
        fun getSystemTypes(): [Type]

        /// Fetches the system capability for the given type.
        ///
        access(all)
        fun getSystemCapability(type: Type): Capability<&AnyResource{Context.Consumer}>

        // --- Entity Manager Methods ---

        /// Fetch the entity manager
        ///
        access(all)
        fun borrowEntityManager(): &EntityManager.Manager

        /// Create a new entity resource with the given UUID.
        ///
        access(all)
        fun createEntity(_ uid: UInt64?): &IEntity.Entity

        /// Destroy the entity resource for the given UUID.
        ///
        access(all)
        fun destroyEntity(uid: UInt64): Void

        /// Returns all available components.
        ///
        access(all)
        fun getAvailableComponents(): [Type]

        /// Passthrough to the entity manager.
        ///
        access(all)
        fun addComponent(_ compType: Type, to: &IEntity.Entity, withData: {String: AnyStruct}?) {
            let entityMgr = self.borrowEntityManager()
            entityMgr.addComponent(compType, to: to, withData: withData)
        }

        /// Passthrough to the entity manager.
        ///
        access(all)
        fun addComponentBatch(_ compType: Type, to: EntityQuery.Builder, ctx: &AnyResource{Context.Provider}) {
            let entityMgr = self.borrowEntityManager()
            entityMgr.addComponentBatch(compType, to: to, ctx: ctx)
        }

        // --- Lifecycle Methods ---

        /// Returns the current time of the world.
        ///
        access(all)
        fun getCurrentTime(): UFix64

        /// Call to update the world.
        ///
        access(all)
        fun update(_ dt: UFix64): Void
    }

    /// The context of the world
    ///
    pub resource World: WorldState, Context.Provider {
        /// The entities in the world.
        access(contract)
        let entities: @{UInt64: IEntity.Entity}

        /**
         * The address of the wrold.
         */
        access(all)
        fun getAddress(): Address {
            return self.owner?.address ?? panic("The world is not initialized yet")
        }

        /// Returns the number of entities in the world.
        ///
        access(all)
        fun entitiesCount(): Int {
            return self.entities.keys.length
        }

        /// Check if the given entity resource exists.
        ///
        access(all)
        fun exists(uid: UInt64): Bool {
            return self.entities.containsKey(uid)
        }

        /// Fetches the list of all entity UUIDs.
        ///
        access(all)
        fun getEntities(): [UInt64] {
            return self.entities.keys
        }

        /// Fetches the entity resource for the given UUID.
        ///
        access(all)
        fun borrowEntity(uid: UInt64): &IEntity.Entity? {
            return &self.entities[uid] as &IEntity.Entity?
        }

        /// Fetches the entity resources for the given UUIDs.
        ///
        access(all)
        fun borrowEntities(uids: [UInt64]): {UInt64: &IEntity.Entity?} {
            let ret: {UInt64: &IEntity.Entity?} = {}
            for uid in uids {
                ret[uid] = self.borrowEntity(uid: uid)
            }
            return ret
        }

        /// Fetches all entity resources' reference
        ///
        access(all)
        fun borrowAllEntities(): [&IEntity.Entity] {
            let ret: [&IEntity.Entity] = []
            for uuid in self.entities.keys {
                ret.append((&self.entities[uuid] as &IEntity.Entity?)!)
            }
            return ret
        }
    }

    /// The public interface of the world manager
    ///
    pub resource interface WorldManagerPublic {
        /// Fetch the world storage path by name
        ///
        access(all)
        fun getWorldStoragePath(_ name: String): StoragePath

        /// Fetch the world public path by name
        ///
        access(all)
        fun getWorldPublicPath(_ name: String): PublicPath
    }

    /// The admin interface of the world manager
    ///
    pub resource interface WorldManagerAdmin {
        // --- World Methods ---

        /// Create a new world
        ///
        access(all)
        fun create(_ name: String, withSystems: [Type]): &World

        /// Borrow the world by name
        ///
        access(all)
        fun borrowWorld(_ name: String): &World?

        /// Iterate all worlds
        ///
        access(all)
        fun forEachWorlds(_ callback: ((String, &World): Void))

        // --- System Methods ---

        /// Add a system to the world
        ///
        access(all)
        fun addSystem(to: String, system: Type): Void

        /// Set enabled status of a system
        ///
        access(all)
        fun setSystemEnabled(to: String, system: Type, enabled: Bool): Void

        /// Remove a system from the world
        ///
        access(all)
        fun removeSystem(from: String, system: Type): Void
    }

    pub resource interface WorldExecutor {
        /// Fetch the world current time
        ///
        access(all) view
        fun getWorldCurrentTime(_ name: String): UFix64

        /// Update the world
        ///
        access(all)
        fun updateWorld(_ name: String, now: UFix64): Void {
            pre {
                self.getWorldCurrentTime(name) < now: "The world time can only be updated forward"
            }
        }

        /// Update all worlds
        ///
        access(all)
        fun updateAllWorlds(now: UFix64): Void
    }

    /// The world manager is responsible for creating and managing worlds.
    ///
    pub resource WorldManager: WorldManagerPublic, WorldManagerAdmin, WorldExecutor {}
}
