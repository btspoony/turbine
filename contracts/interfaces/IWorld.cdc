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
        // The world state will be used to store the entities and systems.

        // TODO: Add:
        //     - the entity manager, which will be used to manage the entities.
        //     - the world configuration, which will be used to store the world configuration.
    }

  /// The system create method
  ///
  pub fun create(): @World
}
