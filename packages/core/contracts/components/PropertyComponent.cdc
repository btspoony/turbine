// Owned imports
import "IComponent"

pub contract PropertyComponent: IComponent {

    /// Events

    pub event PropertySet(uuid: UInt64, key: String, _ valueTypeIdentifier: String)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        init() {
            self.enabled = true
            self.kv = {}
        }

        /// --- Data Provider methods ---

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                self.setKeyValue(k, kv[k])
            }
        }

        /** Private Methods */

        pub fun setKeyValue(_ key: String, _ value: AnyStruct) {
            self.kv[key] = value

            emit PropertySet(
                uuid: self.uuid,
                key: key,
                value.getType().identifier
            )
        }
    }

    /// The component factory resource
    ///
    pub resource Factory: IComponent.ComponentFactory {
        /// The create function for the component factory resource
        ///
        pub fun create(): @Component {
            return <- create Component()
        }

        /// Returns the type of the component
        ///
        pub fun instanceType(): Type {
            return Type<@Component>()
        }
    }

    /// The create function for the entity factory resource
    ///
    pub fun createFactory(): @Factory {
        return <- create Factory()
    }
}
