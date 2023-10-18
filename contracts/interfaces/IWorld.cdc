import "IEntity"
import "Context"
import "EntityManager"

/// The world is the root of the object graph. It contains all the entities in the game.
/// It is also responsible for managing entities.
pub contract interface IWorld {

    pub resource interface WorldState {
        /**
         * The name of the wrold.
         */
        access(all)
        fun getName(): String

        /**
         * The address of the wrold.
         */
        access(all)
        fun getAddress(): Address

        /**
         * The list of system types that the context provider supports.
         */
        access(all)
        fun getSystemTypes(): [Type]

        /**
         * Fetches the system capability for the given type.
         */
        access(all)
        fun getSystemCapability(type: Type): Capability


        /// The entity manager
        ///
        access(all)
        fun borrowEntityManager(): &EntityManager.Manager
    }

    /// The context of the world
    ///
    pub resource World: WorldState, Context.Provider {
        /// The entities in the world.
        pub let entities: @{UInt64: IEntity.Entity}

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
        fun exists(uuid: UInt64): Bool {
            return self.entities.containsKey(uuid)
        }

        /// Fetches the entity resource for the given UUID.
        ///
        access(all)
        fun borrowEntity(uuid: UInt64): &IEntity.Entity? {
            return &self.entities[uuid] as &IEntity.Entity?
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

  /// The world create method
  ///
  pub fun create(): @World
}
