import "IEntity"

/// The context interface provide a way for contracts to access system resources.
///
pub contract Context {

    pub resource interface Provider {
        /// Check if the given entity resource exists.
        ///
        access(all)
        fun exists(uuid: UInt64): Bool

        /// Fetches the entity resource for the given UUID.
        ///
        access(all)
        fun borrowEntity(uuid: UInt64): &IEntity.Entity

        /// Fetches all entity resources' reference
        ///
        access(all)
        fun borrowAllEntities(): [&IEntity.Entity]
    }

    pub resource interface Consumer {
        /**
         * The capability for the context provider.
         */
         access(all)
        fun getProviderCapability(): Capability<&AnyResource{Provider}>

        /**
         * Borrow the context provider.
         */
        access(all)
        fun borrowProvider(): &AnyResource{Provider} {
            return self.getProviderCapability().borrow()
                ?? panic("Unable to borrow provider")
        }
    }
}
