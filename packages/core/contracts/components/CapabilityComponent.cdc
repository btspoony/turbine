// Owned imports
import "IComponent"

pub contract CapabilityComponent: IComponent {

    /// Events

    pub event TargetAddressSet(uuid: UInt64, address: Address)
    pub event CapabilityPathSet(uuid: UInt64, path: CapabilityPath)
    pub event CapabilityTypeSet(uuid: UInt64, type: Type)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        init() {
            self.enabled = true
            self.kv = {}
        }

        /// --- Data Provider methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return ["address", "capability", "path"]
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                switch k {
                case "address":
                    self.kv["address"] = kv[k] as! Address? ?? panic("Invalid address")
                case "capability":
                    self.kv["capability"] = CapabilityType(kv[k] as! Type? ?? panic("Invalid type")) ?? panic("Invalid capability type")
                case "path":
                    self.kv["path"] = kv[k] as! CapabilityPath? ?? panic("Invalid path")
                default:
                    return panic("Invalid key")
                }
            }
        }

        access(all)
        fun getAddress(): Address {
            return self.kv["address"] as! Address? ?? panic("Invalid address")
        }
        access(all)
        fun getCapability(): Type {
            return CapabilityType(self.kv["capability"] as! Type? ?? panic("Invalid type")) ?? panic("Invalid capability type")
        }
        access(all)
        fun path(): CapabilityPath {
            return self.kv["path"] as! CapabilityPath? ?? panic("Invalid path")
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
