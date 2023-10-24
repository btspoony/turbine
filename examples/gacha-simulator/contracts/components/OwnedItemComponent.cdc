// Owned imports
import "IEntity"
import "IComponent"
import "ItemComponent"

pub contract OwnedItemComponent: IComponent {

    /// Events

    /// Structs

    pub struct OwnedItemInfo {
        pub let itemEntityID: UInt64
        pub let exp: UInt64
        pub let level: UInt64
        pub let quality: UInt64
        pub let quantity: UFix64

        init(
            _ itemEntityID: UInt64,
            _ exp: UInt64,
            _ level: UInt64,
            _ quality: UInt64,
            _ quantity: UFix64
        ) {
            self.itemEntityID = itemEntityID
            self.exp = exp
            self.level = level
            self.quality = quality
            self.quantity = quantity
        }

        pub fun toDictionary(): {String: AnyStruct?} {
            return {
                "itemEntityID": self.itemEntityID,
                "exp": self.exp,
                "level": self.level,
                "quality": self.quality,
                "quantity": self.quantity
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

            self.kv["itemEntityID"] = 0
            self.kv["exp"] = 0
            self.kv["level"] = 1
            self.kv["quality"] = 0
            self.kv["quantity"] = 1.0
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "itemEntityID",
                "exp",
                "level",
                "quality",
                "quantity"
            ]
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["itemEntityID"] != nil {
                self.kv["itemEntityID"] = kv["itemEntityID"] as! UInt64? ?? panic("Invalid type for itemEntityID")
            }
            if kv["exp"] != nil {
                self.kv["exp"] = kv["exp"] as! UInt64? ?? panic("Invalid type for exp")
            }
            if kv["level"] != nil {
                self.kv["level"] = kv["level"] as! UInt64? ?? panic("Invalid type for level")
            }
            if kv["quality"] != nil {
                self.kv["quality"] = kv["quality"] as! UInt64? ?? panic("Invalid type for quality")
            }
            if kv["quantity"] != nil {
                self.kv["quantity"] = kv["quantity"] as! UFix64? ?? panic("Invalid type for quantity")
            }
        }

        access(all)
        fun fromStruct(_ info: OwnedItemInfo) {
            self.kv["itemEntityID"] = info.itemEntityID
            self.kv["exp"] = info.exp
            self.kv["level"] = info.level
            self.kv["quality"] = info.quality
            self.kv["quantity"] = info.quantity
        }

        access(all)
        fun toStruct(): OwnedItemInfo {
            return OwnedItemInfo(
                self.kv["itemEntityID"] as! UInt64,
                self.kv["exp"] as! UInt64,
                self.kv["level"] as! UInt64,
                self.kv["quality"] as! UInt64,
                self.kv["quantity"] as! UFix64
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
