// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

pub contract DisplayComponent: IComponent {

    /// Events

    pub event DisplayValueSet(_ uuid: UInt64, _ key: String, _ value: String)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, MetadataViews.Resolver {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        init() {
            self.enabled = true
            self.kv = {}

            self.kv["name"] = "Untitled"
            self.kv["description"] = "No description"
            self.kv["thumbnail"] = ""
        }

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "name",
                "description",
                "thumbnail"
            ]
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                let value = kv[k] as! String? ?? panic("Invalid value type")
                switch k {
                    case "name":
                        self.kv["name"] = value
                        emit DisplayValueSet(self.uuid, k, value)
                    case "description":
                        self.kv["description"] = value
                        emit DisplayValueSet(self.uuid, k, value)
                    case "thumbnail":
                        self.kv["thumbnail"] = value
                        emit DisplayValueSet(self.uuid, k, value)
                    default:
                        break
                }
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
