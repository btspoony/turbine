/// The contract interface for the component resource, which is the base of all components
/// in the system.
///
pub contract interface IComponent {

    pub resource interface DataProvider {
        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String]

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct?

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
        pub fun setData(_ kv: {String: AnyStruct?}): Void
    }

    /// The private interface for an Enableable Component
    ///
    pub resource interface EnableableLifecycle {
        /// Returns if the component is enabled
        pub fun isEnable(): Bool

        /// Sets the component enable status
        ///
        pub fun setEnable(_ enabled: Bool): Void

        /// This method is invoked when the component is enabled
        ///
        pub fun onActivate() {
            return
        }

        /// This method is invoked when the component is disabled
        ///
        pub fun onDetached() {
            return
        }
    }

    /* --- Interfaces & Resources --- */

    pub resource Component: DataProvider, DataSetter, EnableableLifecycle {
        access(contract) var enabled: Bool

        /// Returns if the component is enabled
        ///
        pub fun isEnable(): Bool {
            return self.enabled
        }

        /// Sets the component enable status
        ///
        pub fun setEnable(_ enabled: Bool): Void {
            post {
                self.enabled == enabled: "The component enable status is not set correctly"
            }
            self.enabled = enabled
            if enabled {
                self.onActivate()
            } else {
                self.onDetached()
            }
        }

        /// --- Data methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return []
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            return nil
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
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
