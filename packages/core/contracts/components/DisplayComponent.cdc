// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

pub contract DisplayComponent: IComponent {

    /// Events

    pub event ComponentValueSet(uuid: UInt64, key: String, _ valueTypeIdentifier: String)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.EnableableLifecycle, MetadataViews.Resolver {
        access(contract) var enabled: Bool
        access(self) let kv: {String: AnyStruct}  // key-value store

        init() {
            self.enabled = true
            self.kv = {}
        }

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return self.kv.keys
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            return self.kv[key]
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                self.setKeyValue(k, kv[k])
            }
        }

        /* ---- Default implemation of MetadataViews.Resolver ---- */

        /// Returns the types of supported views - none at this time
        ///
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>()
            ]
        }

        /// Resolves the given view if supported - none at this time
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: (self.getKeyValue("name") as! String?) ?? "Untitled",
                        description: (self.getKeyValue("description") as! String?) ?? "No description",
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.getKeyValue("thumbnail") as! String? ?? "",
                        )
                    )
            }
            return nil
        }

        /** Private Methods */
        pub fun setKeyValue(_ key: String, _ value: AnyStruct) {
            self.kv[key] = value

            emit ComponentValueSet(
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
