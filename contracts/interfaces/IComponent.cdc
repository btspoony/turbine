/// The contract interface for the component resource
///
pub contract interface IComponent {

    pub resource interface DataProvider {
        /// Returns the keys of the component
        pub fun getKeys(): [String]
        /// Returns the value of the key
        pub fun getKeyValue(_ key: String): AnyStruct?
    }

    /// The interface for an Enableable Component
    ///
    pub resource interface Enableable {
        /// Returns if the component is enabled
        pub fun isEnable(): Bool
    }

    /// The private interface for an Enableable Component
    ///
    pub resource interface EnableableLifecycle {
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

    pub resource Component: DataProvider, Enableable, EnableableLifecycle {
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

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String]

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct?
    }

    /// The component factory
    ///
    pub fun create(): @Component
}
