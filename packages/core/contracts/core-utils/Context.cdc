import "IEntity"

/// The context interface provide a way for contracts to access system resources.
///
pub contract Context {

    pub resource interface Provider {
        /// Check if the given entity resource exists.
        ///
        access(all)
        fun exists(uid: UInt64): Bool

        /// Fetches the list of all entity UUIDs.
        ///
        access(all)
        fun getEntities(): [UInt64]

        /// Fetches the entity resource for the given UUID.
        ///
        access(all)
        fun borrowEntity(uid: UInt64): &IEntity.Entity?

        /// Fetches the entity resources for the given UUIDs.
        ///
        access(all)
        fun borrowEntities(uids: [UInt64]): {UInt64: &IEntity.Entity?}

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
