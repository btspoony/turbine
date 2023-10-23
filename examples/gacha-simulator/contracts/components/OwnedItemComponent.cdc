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

        init(
            _ itemEntityID: UInt64,
            _ exp: UInt64,
            _ level: UInt64,
            _ quality: UInt64
        ) {
            self.itemEntityID = itemEntityID
            self.exp = exp
            self.level = level
            self.quality = quality
        }

        pub fun toDictionary(): {String: AnyStruct?} {
            return {
                "itemEntityID": self.itemEntityID,
                "exp": self.exp,
                "level": self.level,
                "quality": self.quality
            }
        }
    }

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool

        access(all)
        var itemEntityID: UInt64
        access(all)
        var exp: UInt64
        access(all)
        var level: UInt64
        access(all)
        var quality: UInt64

        init() {
            self.enabled = true
            self.itemEntityID = 0
            self.exp = 0
            self.level = 1
            self.quality = 0
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "itemEntityID",
                "exp",
                "level",
                "quality"
            ]
        }

        /// Returns the value of the key
        ///
        access(all) fun getKeyValue(_ key: String): AnyStruct? {
            if key == "itemEntityID" {
                return self.itemEntityID
            } else if key == "exp" {
                return self.exp
            } else if key == "level" {
                return self.level
            } else if key == "quality" {
                return self.quality
            } else {
                return nil
            }
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["itemEntityID"] != nil {
                self.itemEntityID = kv["itemEntityID"] as! UInt64? ?? panic("Invalid type for itemEntityID")
            }
            if kv["exp"] != nil {
                self.exp = kv["exp"] as! UInt64? ?? panic("Invalid type for exp")
            }
            if kv["level"] != nil {
                self.level = kv["level"] as! UInt64? ?? panic("Invalid type for level")
            }
            if kv["quality"] != nil {
                self.quality = kv["quality"] as! UInt64? ?? panic("Invalid type for quality")
            }
        }

        access(all)
        fun fromStruct(_ info: OwnedItemInfo) {
            self.itemEntityID = info.itemEntityID
            self.exp = info.exp
            self.level = info.level
            self.quality = info.quality
        }

        access(all)
        fun toStruct(): OwnedItemInfo {
            return OwnedItemInfo(
                self.itemEntityID,
                self.exp,
                self.level,
                self.quality
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
