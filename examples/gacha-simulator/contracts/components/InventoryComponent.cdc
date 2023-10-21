// Owned imports
import "IComponent"

pub contract InventoryComponent: IComponent {

    /// Events
    pub event InventoryReseted(_ uuid: UInt64)

    pub event FungibleItemAdded(_ uuid: UInt64, itemID: UInt64, amount: UInt64)
    pub event FungibleItemRemoved(_ uuid: UInt64, itemID: UInt64, amount: UInt64)
    pub event NonFungibleItemAdded(_ uuid: UInt64, itemID: UInt64)
    pub event NonFungibleItemRemoved(_ uuid: UInt64, itemID: UInt64)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.ComponentState {
        access(contract) var enabled: Bool
        /// Owned fungible items' enitity IDs
        access(all)
        var fungibleItems: {UInt64: UInt64}
        access(all)
        var nonFungibleItems: {UInt64: Bool}

        init() {
            self.enabled = true
            self.fungibleItems = {}
            self.nonFungibleItems = {}
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "fungibleItems",
                "nonFungibleItems"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            switch key {
            case "fungibleItems":
                return self.fungibleItems
            case "nonFungibleItems":
                return self.nonFungibleItems
            default:
                return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            for k in kv.keys {
                switch k {
                    case "fungibleItems":
                        self.fungibleItems = kv["fungibleItems"] as! {UInt64: UInt64}?
                            ?? panic("Failed to set fungibleItems data")
                    case "nonFungibleItems":
                        self.nonFungibleItems = kv["nonFungibleItems"] as! {UInt64: Bool}?
                            ?? panic("Failed to set nonFungibleItems data")
                    default:
                        break
                }
            }

            emit InventoryReseted(self.uuid)
        }

        /// --- Component Specific methods ---

        /// Adds a fungible item to the inventory
        ///
        pub fun addFungibleItem(_ itemID: UInt64, _ amount: UInt64): Void {
            if self.fungibleItems[itemID] == nil {
                self.fungibleItems[itemID] = amount
            } else {
                self.fungibleItems[itemID] = self.fungibleItems[itemID]!.saturatingAdd(amount)
            }

            emit FungibleItemAdded(self.uuid, itemID: itemID, amount: amount)
        }

        /// Removes a fungible item from the inventory
        ///
        pub fun removeFungibleItem(_ itemID: UInt64, _ amount: UInt64): Void {
            if self.fungibleItems[itemID] == nil {
                panic("Item does not exist in inventory")
            } else {
                self.fungibleItems[itemID] = self.fungibleItems[itemID]!.saturatingSubtract(amount)
            }

            emit FungibleItemRemoved(self.uuid, itemID: itemID, amount: amount)
        }

        /// Adds a non-fungible item to the inventory
        ///
        pub fun addNonFungibleItem(_ itemID: UInt64): Void {
            self.nonFungibleItems[itemID] = true

            emit NonFungibleItemAdded(self.uuid, itemID: itemID)
        }

        /// Removes a non-fungible item from the inventory
        ///
        pub fun removeNonFungibleItem(_ itemID: UInt64): Void {
            if self.nonFungibleItems[itemID] == nil {
                panic("Item does not exist in inventory")
            } else {
                self.nonFungibleItems.remove(key: itemID)
            }

            emit NonFungibleItemRemoved(self.uuid, itemID: itemID)
        }

        /// Returns the amount of a fungible item in the inventory
        ///
        pub fun getFungibleItemAmount(_ itemID: UInt64): UInt64 {
            if self.fungibleItems[itemID] == nil {
                return 0
            } else {
                return self.fungibleItems[itemID]!
            }
        }

        /// Returns whether a non-fungible item is in the inventory
        ///
        pub fun hasNonFungibleItem(_ itemID: UInt64): Bool {
            return self.nonFungibleItems[itemID] != nil
        }

        /// Returns whether a fungible item is in the inventory
        ///
        pub fun hasFungibleItem(_ itemID: UInt64): Bool {
            return self.fungibleItems[itemID] != nil
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
