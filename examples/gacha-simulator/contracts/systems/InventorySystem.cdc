import "Context"
import "IEntity"
import "IWorld"
import "ISystem"
import "InventoryComponent"
import "ItemComponent"
import "OwnedItemComponent"

pub contract InventorySystem: ISystem {

    // Events
    pub event FungibleItemAddedToInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64, amount: UFix64)
    pub event FungibleItemRemovedFromInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64, amount: UFix64)
    pub event NonFungibleItemAddedToInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64)
    pub event NonFungibleItemRemovedFromInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64)

    pub resource System: ISystem.CoreLifecycle, Context.Consumer {
        access(contract)
        let worldCap: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        access(contract)
        var enabled: Bool

        init(
            _ world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ) {
            self.worldCap = world
            self.enabled = true
        }

        /// Add an item to the player's inventory
        /// Returns the owned item id
        ///
        access(all)
        fun addItemToInventory(_ playerId: UInt64, _ itemEntityId: UInt64, amount: UFix64?): UInt64 {
            let playerInventory = self.borrowInventory(playerId)
            let item = self.borrowItem(itemEntityId)

            var ownedId: UInt64? = nil
            let itemInfo = item.toStruct()
            if itemInfo.fungible {
                let addedAmount = amount ?? 1.0
                if let existingOwnedItemId = playerInventory.getOwnedItemIdByOriginItemId(itemEntityId) {
                    ownedId = existingOwnedItemId
                    let ownedItem: &OwnedItemComponent.Component = self.borrowOwnedItem(existingOwnedItemId)
                    let ownedItemInfo = ownedItem.toStruct()
                    assert(ownedItemInfo.itemEntityID == itemEntityId, message: "Owned item does not match item entity id")
                    ownedItem.setData({ "quantity": ownedItemInfo.quantity + addedAmount })
                } else {
                    ownedId = self.createNewOwnedEntity(itemEntityId)
                    playerInventory.addOwnedItem(ownedId!, itemEntityId)
                    let newOwnedItem = self.borrowOwnedItem(ownedId!)
                    newOwnedItem.setData({ "quantity": addedAmount })
                }
                emit FungibleItemAddedToInventory(playerId, itemEntityId, ownedId!, amount: addedAmount)
            } else {
                ownedId = self.createNewOwnedEntity(itemEntityId)
                playerInventory.addOwnedItem(ownedId!, itemEntityId)
                emit NonFungibleItemAddedToInventory(playerId, itemEntityId, ownedId!)
            }
            return ownedId!
        }

        /// Removes an item from the player's inventory
        ///
        access(all)
        fun removeFungibleItem(_ playerId: UInt64, _ itemEntityId: UInt64, amount: UFix64) {
            let playerInventory = self.borrowInventory(playerId)
            let item = self.borrowItem(itemEntityId)

            let itemInfo = item.toStruct()
            assert(itemInfo.fungible, message: "Item is not fungible")

            let ownedItemId = playerInventory.getOwnedItemIdByOriginItemId(itemEntityId)
            assert(ownedItemId != nil, message: "Player does not own item")

            let ownedItem: &OwnedItemComponent.Component = self.borrowOwnedItem(ownedItemId!)
            let ownedItemInfo = ownedItem.toStruct()

            assert(ownedItemInfo.quantity >= amount, message: "Not enough items to remove")

            // Update owned item quantity
            ownedItem.setData({ "quantity": ownedItemInfo.quantity.saturatingSubtract(amount) })

            // Emit event
            emit FungibleItemRemovedFromInventory(playerId, itemEntityId, ownedItemId!, amount: amount)
        }

        access(all)
        fun removeNonFungibleItem(_ playerId: UInt64, _ ownedItemId: UInt64) {
            let playerInventory = self.borrowInventory(playerId)
            let ownedItem = self.borrowOwnedItem(ownedItemId)

            let info = ownedItem.toStruct()
            let item = self.borrowItem(info.itemEntityID)
            assert(item.toStruct().fungible == false, message: "Item is not non-fungible")
            assert(playerInventory.hasOwnedtem(ownedItemId), message: "Player does not own item")

            playerInventory.removeOwnedItem(ownedItemId)

            // Destroy the owned item entity
            self.borrowWorld().destroyEntity(uid: ownedItemId)

            // Emit event
            emit NonFungibleItemRemovedFromInventory(playerId, info.itemEntityID, ownedItemId)
        }

        // --- ISystem.CoreLifecycle ---

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // TODO: Implement, expiring items with item lifetime component
        }

        // --- Internal ---

        /// Create a new owned item entity
        ///
        access(self)
        fun createNewOwnedEntity(_ itemEntityId: UInt64): UInt64 {
            // ensure item exists
            self.borrowItem(itemEntityId)

            // Manager
            let world = self.borrowWorld()
            let entityMgr = world.borrowEntityManager()

            // create owned item entity
            let owned = world.createEntity(nil)
            // add owned item component
            entityMgr.addComponent(
                Type<@OwnedItemComponent.Component>(),
                to: owned,
                withData: { "itemEntityID": itemEntityId }
            )
            return owned.getId()
        }

        /// Borrow the Inventory component from the player
        ///
        access(self)
        fun borrowInventory(_ playerId: UInt64): &InventoryComponent.Component {
            let playerEntity = self.borrowEntity(playerId)
            let comp = playerEntity.borrowComponent(Type<@InventoryComponent.Component>())
                ?? panic("Player does not have an inventory")
            return comp as! &InventoryComponent.Component
        }

        /// Borrow the item component from the item entity
        ///
        access(self)
        fun borrowItem(_ itemId: UInt64): &ItemComponent.Component {
            let itemEntity = self.borrowEntity(itemId)
            let comp = itemEntity.borrowComponent(Type<@ItemComponent.Component>())
                ?? panic("Item does not exist")
            return comp as! &ItemComponent.Component
        }

        /// Borrow the owned item component from the owned item entity
        ///
        access(self)
        fun borrowOwnedItem(_ itemId: UInt64): &OwnedItemComponent.Component {
            let itemEntity = self.borrowEntity(itemId)
            let comp = itemEntity.borrowComponent(Type<@OwnedItemComponent.Component>())
                ?? panic("Item does not exist")
            return comp as! &OwnedItemComponent.Component
        }
    }

    /// The system factory resource
    ///
    pub resource SystemFactory: ISystem.SystemFactory {
        /// Creates a new system
        ///
        pub fun create(
            world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ): @System {
            return <- create System(world)
        }

        /// Returns the type of the system
        ///
        pub fun instanceType(): Type {
            return Type<@System>()
        }
    }

    /// The create function for the system factory resource
    ///
    pub fun createFactory(): @SystemFactory {
        return <- create SystemFactory()
    }
}
