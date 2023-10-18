import "Context"

/// The world is the root of the object graph. It contains all the entities in the game.
/// It is also responsible for managing entities.
pub contract interface IWorld {

    /// The context of the world
    ///
    pub resource World: Context.Provider {
        // The world state will be used to store the entities and systems.

        // TODO: Add:
        //     - the entity manager, which will be used to manage the entities.
        //     - the world configuration, which will be used to store the world configuration.
    }

  /// The system create method
  ///
  pub fun create(): @World
}
