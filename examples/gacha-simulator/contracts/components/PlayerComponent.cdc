// Owned imports
import "IComponent"

pub contract PlayerComponent: IComponent {

    /// Events

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.ComponentState {
        access(contract) var enabled: Bool

        /// The player's gacha pool counter { gachaPoolId: gachaPoolCounter }
        access(all)
        var gachaPoolCounter: {UInt64: UInt64}
        /// The player's gacha pool last pulled rare { gachaPoolId: itemEntityId }
        access(all)
        var gachaPoolLastPulledRare: {UInt64: UInt64}
        /// The player's experience
        access(all)
        var exp: UInt64
        /// The player's level
        access(all)
        var level: UInt64

        init() {
            self.enabled = true
            self.gachaPoolCounter = {}
            self.gachaPoolLastPulledRare = {}
            self.exp = 0
            self.level = 1
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "gachaPoolCounter",
                "gachaPoolLastPulledRare",
                "exp",
                "level"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            if key == "gachaPoolCounter" {
                return self.gachaPoolCounter
            } else if key == "gachaPoolLastPulledRare" {
                return self.gachaPoolLastPulledRare
            } else if key == "exp" {
                return self.exp
            } else if key == "level" {
                return self.level
            } else {
                return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["gachaPoolCounter"] != nil {
                self.gachaPoolCounter = kv["gachaPoolCounter"] as! {UInt64: UInt64}
            }
            if kv["gachaPoolLastPulledRare"] != nil {
                self.gachaPoolLastPulledRare = kv["gachaPoolLastPulledRare"] as! {UInt64: UInt64}
            }
            if kv["exp"] != nil {
                self.exp = kv["exp"] as! UInt64
            }
            if kv["level"] != nil {
                self.level = kv["level"] as! UInt64
            }
        }

        /// --- Component Specific methods ---

        /// Returns the player's gacha pool counter
        ///
        access(all)
        fun getGachaPoolCounter(_ gachaPoolId: UInt64): UInt64 {
            return self.gachaPoolCounter[gachaPoolId] ?? 0
        }

        /// Sets the player's gacha pool counter
        ///
        access(all)
        fun setGachaPoolCounter(_ gachaPoolId: UInt64, _ counter: UInt64): Void {
            self.gachaPoolCounter[gachaPoolId] = counter
        }

        /// Increments the player's gacha pool counter
        ///
        access(all)
        fun incrementGachaPoolCounter(_ gachaPoolId: UInt64): Void {
            self.gachaPoolCounter[gachaPoolId] = (self.gachaPoolCounter[gachaPoolId] ?? 0) + 1
        }

        /// Returns the player's gacha pool last pulled rare
        ///
        access(all)
        fun setGachaPoolLastPulledRare(_ gachaPoolId: UInt64, _ itemEntityId: UInt64): Void {
            self.gachaPoolLastPulledRare[gachaPoolId] = itemEntityId
        }

        /// Returns the player's gacha pool last pulled rare
        ///
        access(all)
        fun getGachaPoolLastPulledRare(_ gachaPoolId: UInt64): UInt64? {
            return self.gachaPoolLastPulledRare[gachaPoolId]
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
