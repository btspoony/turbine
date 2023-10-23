// Owned imports
import "IComponent"

pub contract ItemComponent: IComponent {

    /// Events

    /// Structs and Resources

    pub enum ItemCategory: UInt8 {
        pub case Character
        pub case Weapon
        pub case Consumable
        pub case QuestItem
    }

    pub struct ItemInfo {
        access(all)
        let category: ItemCategory
        access(all)
        let fungible: Bool
        access(all)
        let identity: String
        access(all)
        let rarity: UInt8
        access(all)
        let traits: {String: UInt8}

        init(
            _ category: ItemCategory,
            _ fungible: Bool,
            _ identity: String,
            _ rarity: UInt8,
            _ traits: {String: UInt8}
        ) {
            self.category = category
            self.fungible = fungible
            self.identity = identity
            self.rarity = rarity
            self.traits = traits
        }

        pub fun toDictionary(): {String: AnyStruct?} {
            return {
                "category": self.category,
                "fungible": self.fungible,
                "identity": self.identity,
                "rarity": self.rarity,
                "traits": self.traits
            }
        }
    }

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        init() {
            self.enabled = true
            self.kv = {}
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "category",
                "fungible",
                "identity",
                "rarity",
                "traits"
            ]
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["category"] != nil {
                self.kv["category"] = kv["category"] as! ItemCategory? ?? panic("Invalid type for category")
            }
            if kv["fungible"] != nil {
                self.kv["fungible"] = kv["fungible"] as! Bool? ?? panic("Invalid type for fungible")
            }
            if kv["identity"] != nil {
                self.kv["identity"] = kv["identity"] as! String? ?? panic("Invalid type for identity")
            }
            if kv["rarity"] != nil {
                self.kv["rarity"] = kv["rarity"] as! UInt8? ?? panic("Invalid type for rarity")
            }
            if kv["traits"] != nil {
                self.kv["traits"] = kv["traits"] as! {String: UInt8}? ?? panic("Invalid type for traits")
            }
        }

        /// Sets the state of the component
        ///
        pub fun fromStruct(_ info: ItemInfo): Void {
            self.kv["category"]  = info.category
            self.kv["fungible"]  = info.fungible
            self.kv["identity"]  = info.identity
            self.kv["rarity"]    = info.rarity
            self.kv["traits"]    = info.traits
        }

        /// Returns the state of the component
        ///
        pub fun toStruct(): ItemInfo {
            return ItemInfo(
                self.getKeyValue("category") as! ItemCategory? ?? panic("Invalid type for category"),
                self.getKeyValue("fungible") as! Bool? ?? panic("Invalid type for fungible"),
                self.getKeyValue("identity") as! String? ?? panic("Invalid type for identity"),
                self.getKeyValue("rarity") as! UInt8? ?? panic("Invalid type for rarity"),
                self.getKeyValue("traits") as! {String: UInt8}? ?? panic("Invalid type for traits")
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
