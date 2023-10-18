import "IEntity"
import "IComponent"
import "IWorld"
import "ISystem"
import "Context"
import "EntityManager"
import "EntityQuery"

pub contract CoreWorld: IWorld {
    /// The context of the world
    ///
    pub resource World: IWorld.WorldState, Context.Provider {
        /// The entities in the world.
        pub let entities: @{UInt64: IEntity.Entity}

        init() {
            self.entities <- {}
        }

        destroy() {
            destroy self.entities
        }

        // --- System Related ---
        // TODO: Add system related methods
    }

    /// The world create method
    ///
    pub fun create(): @World {
        return <- create World()
    }
}
