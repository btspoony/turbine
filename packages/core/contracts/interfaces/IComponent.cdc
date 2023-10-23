/// The contract interface for the component resource, which is the base of all components
/// in the system.
///
pub contract interface IComponent {

    pub resource interface DataProvider {
        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String]

        /// Returns the value of the key
        ///
        access(all) fun getKeyValue(_ key: String): AnyStruct?

        /// Returns the data of the component
        ///
        pub fun getData(): {String: AnyStruct} {
            let keys = self.getKeys()
            let data: {String: AnyStruct} = {}
            for key in keys {
                data[key] = self.getKeyValue(key)
            }
            return data
        }
    }

    pub resource interface DataSetter {
        /// Sets the value of the key
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void
    }

    /* --- Interfaces & Resources --- */

    pub resource Component: DataProvider, DataSetter {
        access(all)
        var enabled: Bool

        /// Sets the component enable status
        /// Can only be called by the CoreEntity contract
        /// TODO: add entitlement access check in Stable Cadence.
        ///
        access(all)
        fun setEnabled(_ enabled: Bool): Void {
            post {
                self.enabled == enabled: "The component enable status is not set correctly"
            }
            self.enabled = enabled
        }

        /// --- Data methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return []
        }

        /// Returns the value of the key
        ///
        access(all) fun getKeyValue(_ key: String): AnyStruct? {
            return nil
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            panic("The component does not support data setting")
        }
    }

    /// The component factory resource
    ///
    pub resource interface ComponentFactory {
        /// Creates a new entity
        ///
        pub fun create(): @Component

        /// Returns the type of the component
        ///
        pub fun instanceType(): Type

        /// Returns the storage path of the component factory
        ///
        pub fun getStoragePath(): StoragePath {
            let identifier = "Turbine.ComponentFactory.".concat(self.getType().identifier)
            return StoragePath(identifier: identifier)!
        }
    }

    /// The create function for the entity factory resource
    ///
    pub fun createFactory(): @{ComponentFactory}
}
