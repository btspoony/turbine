import "IEntity"

/// The context interface provide a way for contracts to access system resources.
///
pub contract Context {

    pub resource interface Provider {
        /// The name of the wrold.
        ///
        access(all)
        fun getName(): String

        /// The address of the wrold.
        ///
        access(all)
        fun getAddress(): Address

        /// The list of consumer types that the context provider supports.
        ///
        access(all)
        fun getSystemTypes(): [Type]

        /// Fetches the consumer capability for the given type.
        ///
        access(all)
        fun getSystemCapability(type: Type): Capability<&AnyResource{Consumer}>

        /// Check if the given entity resource exists.
        ///
        access(all)
        fun exists(uuid: UInt64): Bool

        /// Fetches the entity resource for the given UUID.
        ///
        access(all)
        fun borrowEntity(uuid: UInt64): &IEntity.Entity?

        /// Fetches all entity resources' reference
        ///
        access(all)
        fun borrowAllEntities(): [&IEntity.Entity]
    }

    pub resource interface Consumer {
        /// The capability for the context provider.
        ///
        access(all)
        fun getProviderCapability(): Capability<&AnyResource{Provider}>

        /// Borrow the context provider.
        ///
        access(all)
        fun borrowProvider(): &AnyResource{Provider} {
            return self.getProviderCapability().borrow()
                ?? panic("Unable to borrow provider")
        }
    }
}
