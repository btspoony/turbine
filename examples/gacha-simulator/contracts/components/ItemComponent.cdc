// Owned imports
import "IComponent"

pub contract ItemComponent: IComponent {

    /// Events

    /// Structs and Resources

    pub struct ItemInfo {
        access(all)
        let category: String
        access(all)
        let identity: String
        access(all)
        let rarity: UInt8
        access(all)
        let traits: {String: UInt8}

        init(
            _ category: String,
            _ identity: String,
            _ rarity: UInt8,
            _ traits: {String: UInt8}
        ) {
            self.category = category
            self.identity = identity
            self.rarity = rarity
            self.traits = traits
        }

        pub fun toDictionary(): {String: AnyStruct?} {
            return {
                "category": self.category,
                "identity": self.identity,
                "rarity": self.rarity,
                "traits": self.traits
            }
        }
    }

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.ComponentState {
        access(contract) var enabled: Bool

        access(all)
        var category: String
        access(all)
        var identity: String
        access(all)
        var rarity: UInt8
        access(all)
        var traits: {String: UInt8}

        init() {
            self.enabled = true
            self.category = ""
            self.identity = ""
            self.rarity = 0
            self.traits = {}
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "category",
                "identity",
                "rarity",
                "traits"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            if key == "category" {
                return self.category
            } else if key == "identity" {
                return self.identity
            } else if key == "rarity" {
                return self.rarity
            } else if key == "traits" {
                return self.traits
            } else {
                return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["category"] != nil {
                self.category = kv["category"] as! String? ?? panic("Invalid type for category")
            }
            if kv["identity"] != nil {
                self.identity = kv["identity"] as! String? ?? panic("Invalid type for identity")
            }
            if kv["rarity"] != nil {
                self.rarity = kv["rarity"] as! UInt8? ?? panic("Invalid type for rarity")
            }
            if kv["traits"] != nil {
                self.traits = kv["traits"] as! {String: UInt8}? ?? panic("Invalid type for traits")
            }
        }

        /// Sets the state of the component
        ///
        pub fun fromStruct(_ info: ItemInfo): Void {
            self.category = info.category
            self.identity = info.identity
            self.rarity = info.rarity
            self.traits = info.traits
        }

        /// Returns the state of the component
        ///
        pub fun toStruct(): ItemInfo {
            return ItemInfo(
                self.category,
                self.identity,
                self.rarity,
                self.traits
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
