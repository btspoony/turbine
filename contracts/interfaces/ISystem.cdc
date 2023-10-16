import "IContext"

/// The contract interface for the entity resource
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

  pub resource System: CoreLifecycle, IContext.Consumer {
    
  }

  /// The system create method
  ///
  pub fun create(): @System
}