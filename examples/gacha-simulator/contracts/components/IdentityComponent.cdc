// Owned imports
import "IComponent"

pub contract IdentityComponent: IComponent {

    /// Events

    pub event UsernameSet(_ uuid: UInt64, username: String)
    pub event EmailSet(_ uuid: UInt64, email: String)
    pub event LinkedAddrSet(_ uuid: UInt64, linkedAddr: Address)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.ComponentState {
        access(contract) var enabled: Bool

        access(all)
        var username: String?
        access(all)
        var email: String?
        access(all)
        var linkedAddr: Address?

        init() {
            self.enabled = true
            self.username = nil
            self.email = nil
            self.linkedAddr = nil
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "username",
                "email",
                "linkedAddr"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            if key == "username" {
                return self.username
            }
            if key == "email" {
                return self.email
            }
            if key == "linkedAddr" {
                return self.linkedAddr
            }
            return nil
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["username"] != nil {
                self.setUsername(kv["username"] as! String? ?? panic("Invalid username"))
            }
            if kv["email"] != nil {
                self.setEmail(kv["email"] as! String? ?? panic("Invalid email"))
            }
            if kv["linkedAddr"] != nil {
                self.setLinkedAddr(kv["linkedAddr"] as! Address? ?? panic("Invalid linkedAddr"))
            }
        }

        /// --- Component Specific methods ---

        access(all)
        fun setUsername(_ username: String): Void {
            self.username = username

            emit UsernameSet(self.uuid, username: username)
        }

        access(all)
        fun setEmail(_ email: String): Void {
            self.email = email

            emit EmailSet(self.uuid, email: email)
        }

        access(all)
        fun setLinkedAddr(_ linkedAddr: Address): Void {
            self.linkedAddr = linkedAddr

            emit LinkedAddrSet(self.uuid, linkedAddr: linkedAddr)
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
