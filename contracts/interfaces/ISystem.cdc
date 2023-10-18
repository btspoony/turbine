import "Context"
import "IEntity"
import "IComponent"

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
        /**
         * Called when the system is created
         */
        pub fun onCreate(): Void {
            return
        }

        /**
         * Called before the first call to OnUpdate and whenever a system resumes running.
         */
        pub fun onStartRunning(): Void {
            return
        }

        /**
         * System event callback to add the work that your system must perform every frame.
         */
        pub fun onUpdate(): Void {
            panic("Cannot call onUpdate on a system that does not implement it")
        }
        /**
         * Called when the system is stopped either because the system is being destroyed or the
         * system is no longer enabled.
         */
        pub fun onStopRunning(): Void {
            return
        }

        /**
         * Called when the system is destroyed
         */
        pub fun OnDestroy(): Void {
            return
        }
    }

    /// The system interface
    pub resource System: CoreLifecycle, Context.Consumer {
        access(contract) let worldCap: Capability<&AnyResource{Context.Provider}>

        /**
         * The capability for the context provider.
         */
        pub fun getProviderCapability(): Capability<&AnyResource{Context.Provider}> {
            return self.worldCap
        }
    }

    /// The system create method
    ///
    pub fun create(): @System
}
