// Owned imports
import "IComponent"

pub contract CapabilityComponent: IComponent {

    /// Events

    pub event TargetAddressSet(uuid: UInt64, address: Address)
    pub event CapabilityPathSet(uuid: UInt64, path: CapabilityPath)
    pub event CapabilityTypeSet(uuid: UInt64, type: Type)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.EnableableLifecycle {
        access(contract) var enabled: Bool
        access(all) var address: Address?
        access(all) var capability: Type?
        access(all) var path: CapabilityPath?

        init() {
            self.enabled = true
            self.address = nil
            self.capability = nil
            self.path = nil
        }

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return ["address", "capability", "path"]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            switch key {
            case "address":
                return self.address
            case "capability":
                return self.capability
            case "path":
                return self.path
            default:
                return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                switch k {
                case "address":
                    self.address = kv[k] as! Address? ?? panic("Invalid address")
                case "capability":
                    self.capability = CapabilityType(kv[k] as! Type? ?? panic("Invalid type")) ?? panic("Invalid capability type")
                case "path":
                    self.path = kv[k] as! CapabilityPath? ?? panic("Invalid path")
                default:
                    return panic("Invalid key")
                }
            }
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
