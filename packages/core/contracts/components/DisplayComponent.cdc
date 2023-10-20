// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

pub contract DisplayComponent: IComponent {

    /// Events

    pub event DisplayValueSet(_ uuid: UInt64, _ key: String, _ value: String)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.EnableableLifecycle, MetadataViews.Resolver {
        access(contract) var enabled: Bool
        access(self) var name: String
        access(self) var description: String
        access(self) var thumbnail: String
        access(self) let extra: {String: AnyStruct}

        init() {
            self.enabled = true
            self.name = "Untitled"
            self.description = "No description"
            self.thumbnail = ""
            self.extra = {}
        }

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "name",
                "description",
                "thumbnail"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            switch key {
                case "name":
                    return self.name
                case "description":
                    return self.description
                case "thumbnail":
                    return self.thumbnail
                default:
                    return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                let value = kv[k] as! String?
                switch k {
                    case "name":
                        self.name = value ?? "Untitled"
                        emit DisplayValueSet(self.uuid, k, self.name)
                    case "description":
                        self.description = kv[k] as! String? ?? "No description"
                        emit DisplayValueSet(self.uuid, k, self.description)
                    case "thumbnail":
                        self.thumbnail = kv[k] as! String? ?? ""
                        emit DisplayValueSet(self.uuid, k, self.thumbnail)
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
