// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

pub contract DisplayComponent: IComponent {

    pub resource Component: IComponent.DataProvider, IComponent.Enableable, IComponent.EnableableLifecycle, MetadataViews.Resolver {
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
        }
    }

    /// The component factory
    ///
    pub fun create(): @Component {
        return <- create Component()
    }
}
