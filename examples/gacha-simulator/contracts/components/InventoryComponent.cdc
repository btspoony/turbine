// Owned imports
import "IComponent"

pub contract InventoryComponent: IComponent {

    /// Events
    pub event InventoryReseted(_ uuid: UInt64)

    pub event SimpleItemAdded(_ uuid: UInt64, itemID: UInt64, amount: UFix64)
    pub event SimpleItemRemoved(_ uuid: UInt64, itemID: UInt64, amount: UFix64)
    pub event OwnedItemAdded(_ uuid: UInt64, itemID: UInt64, originItemID: UInt64)
    pub event OwnedItemRemoved(_ uuid: UInt64, itemID: UInt64)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        /// simple fungible items' enitity IDs: amount
        /// Key is EntityId with ItemComponent
        access(all)
        var simpleItems: {UInt64: UFix64}
        /// Owned items' enitity IDs
        /// Key is EntityId with OwnedItemComponent
        access(all)
        var ownedItems: {UInt64: Bool}
        /// Owned items' orginal enitity IDs
        access(all)
        var ownedOrginalItems: {UInt64: UInt64}

        init() {
            self.enabled = true
            self.kv = {}

            self.simpleItems = {}
            self.ownedItems = {}
            self.ownedOrginalItems = {}
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "simpleItems",
                "ownedItems",
                "ownedOrginalItems"
            ]
        }

        /// Returns the value of the key
        ///
        access(all) fun getKeyValue(_ key: String): AnyStruct? {
            switch key {
            case "simpleItems":
                return self.simpleItems
            case "ownedItems":
                return self.ownedItems
            case "ownedOrginalItems":
                return self.ownedOrginalItems
            default:
                return nil
            }
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct}): Void {
            for k in kv.keys {
                switch k {
                    case "simpleItems":
                        self.simpleItems = kv["simpleItems"] as! {UInt64: UFix64}?
                            ?? panic("Failed to set simpleItems data")
                    case "ownedItems":
                        self.ownedItems = kv["ownedItems"] as! {UInt64: Bool}?
                            ?? panic("Failed to set ownedItems data")
                    case "ownedOrginalItems":
                        self.ownedOrginalItems = kv["ownedOrginalItems"] as! {UInt64: UInt64}?
                            ?? panic("Failed to set ownedOrginalItems data")
                    default:
                        break
                }
            }

            emit InventoryReseted(self.uuid)
        }

        /// --- Component Specific methods ---

        /// Returns the simple items
        ///
        pub fun getSimpleItemIds(): [UInt64] {
            return self.simpleItems.keys
        }

        /// Returns the owned items
        ///
        pub fun getOwnedItemIds(): [UInt64] {
            return self.ownedItems.keys
        }

        /// Adds a simple item to the inventory
        ///
        pub fun addSimpleItem(_ itemID: UInt64, _ amount: UFix64): Void {
            if self.simpleItems[itemID] == nil {
                self.simpleItems[itemID] = amount
            } else {
                self.simpleItems[itemID] = self.simpleItems[itemID]!.saturatingAdd(amount)
            }

            emit SimpleItemAdded(self.uuid, itemID: itemID, amount: amount)
        }

        /// Removes a simple item from the inventory
        ///
        pub fun removeSimpleItem(_ itemID: UInt64, _ amount: UFix64): Void {
            if self.simpleItems[itemID] == nil {
                panic("Item does not exist in inventory")
            } else {
                self.simpleItems[itemID] = self.simpleItems[itemID]!.saturatingSubtract(amount)
            }

            emit SimpleItemRemoved(self.uuid, itemID: itemID, amount: amount)
        }

        /// Adds a owned item to the inventory
        ///
        pub fun addOwnedItem(_ ownedItemID: UInt64, _ originItemID: UInt64): Void {
            if self.ownedItems[ownedItemID] == nil {
                self.ownedItems[ownedItemID] = true
                self.ownedOrginalItems[originItemID] = ownedItemID

                emit OwnedItemAdded(self.uuid, itemID: ownedItemID, originItemID: originItemID)
            }
        }

        /// Removes a owned item from the inventory
        ///
        pub fun removeOwnedItem(_ itemID: UInt64): Void {
            if self.ownedItems[itemID] == nil {
                panic("Item does not exist in inventory")
            }
            // Remove owned item
            self.ownedItems.remove(key: itemID)

            // Remove origin item
            for originItemId in self.ownedOrginalItems.keys {
                if self.ownedOrginalItems[originItemId] == itemID {
                    self.ownedOrginalItems.remove(key: originItemId)
                    break
                }
            }

            emit OwnedItemRemoved(self.uuid, itemID: itemID)
        }

        /// Returns the amount of a fungible item in the inventory
        ///
        pub fun getSimpleItemAmount(_ itemID: UInt64): UFix64 {
            if self.simpleItems[itemID] == nil {
                return 0.0
            } else {
                return self.simpleItems[itemID]!
            }
        }

        /// Returns whether a owned item is in the inventory
        ///
        pub fun hasOwnedtem(_ itemID: UInt64): Bool {
            return self.ownedItems[itemID] != nil || self.ownedOrginalItems[itemID] != nil
        }

        /// Returns the owned item ID by the origin item ID
        ///
        pub fun getOwnedItemIdByOriginItemId(_ originItemID: UInt64): UInt64? {
            return self.ownedOrginalItems[originItemID]
        }

        /// Returns whether a fungible item is in the inventory
        ///
        pub fun hasSimpleItem(_ itemID: UInt64): Bool {
            return self.simpleItems[itemID] != nil
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
