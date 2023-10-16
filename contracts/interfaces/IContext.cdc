/// The context interface provide a resource to access system resources.
///
pub contract interface IContext {

  pub resource interface Provider {
    /**
     * The address of the context provider.
     */
    pub fun getAddress(): Address
    /**
     * The list of system types that the context provider supports.
     */
    pub fun getSystemTypes(): [Type]
    /**
     * Fetches the system capability for the given type.
     */
    pub fun getSystemCapability(type: Type): Capability
  }

  pub resource interface Consumer {
    /**
     * The capability for the context provider.
     */
    pub fun getProviderCapability(): Capability<&AnyResource{Provider}>
  }
}
