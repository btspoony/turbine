import "Context"
import "IWorld"
import "ISystem"
import "InventoryComponent"
import "ItemComponent"
import "OwnedItemComponent"

pub contract InventorySystem: ISystem {

    // Events
    pub event FungibleItemAddedToInventory(_ playerId: UInt64, _ itemId: UInt64, _ amount: UFix64)
    pub event NonFungibleItemAddedToInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64)
    pub event FungibleItemRemovedFromInventory(_ playerId: UInt64, _ itemId: UInt64, _ amount: UFix64)
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

        access(all)
        fun addItemToInventory(_ playerId: UInt64, _ itemEntityId: UInt64, amount: UFix64?) {
            let playerInventory = self.borrowInventory(playerId)
            let item = self.borrowItem(itemEntityId)

            let itemInfo = item.toStruct()
            if itemInfo.fungible {
                let addedAmount = amount ?? 1.0
                playerInventory.addFungibleItem(itemEntityId, addedAmount)
                emit FungibleItemAddedToInventory(playerId, itemEntityId, addedAmount)
            } else {
                // create owned item entity
                let world = self.borrowWorld()
                let owned = world.createEntity(nil)
                // add owned item component
                let entityMgr = world.borrowEntityManager()
                entityMgr.addComponent(
                    Type<@OwnedItemComponent.Component>(),
                    to: owned,
                    withData: {
                        "itemEntityID": itemEntityId
                    }
                )

                playerInventory.addNonFungibleItem(owned.getId())
                emit NonFungibleItemAddedToInventory(playerId, itemEntityId, owned.getId())
            }
        }

        access(all)
        fun removeFungibleItem(_ playerId: UInt64, _ itemEntityId: UInt64, amount: UFix64) {
            let playerInventory = self.borrowInventory(playerId)
            let item = self.borrowItem(itemEntityId)

            let itemInfo = item.toStruct()
            assert(itemInfo.fungible, message: "Item is not fungible")

            let currentAmt = playerInventory.getFungibleItemAmount(itemEntityId)
            assert(currentAmt >= amount, message: "Not enough items to remove")

            playerInventory.removeFungibleItem(itemEntityId, amount)

            emit FungibleItemRemovedFromInventory(playerId, itemEntityId, amount)
        }

        access(all)
        fun removeNonFungibleItem(_ playerId: UInt64, _ ownedItemId: UInt64) {
            let playerInventory = self.borrowInventory(playerId)
            let ownedItem = self.borrowOwnedItem(ownedItemId)

            let info = ownedItem.toStruct()
            let item = self.borrowItem(info.itemEntityID)
            assert(item.toStruct().fungible == false, message: "Item is not non-fungible")
            assert(playerInventory.hasNonFungibleItem(ownedItemId), message: "Player does not own item")

            playerInventory.removeNonFungibleItem(ownedItemId)

            emit NonFungibleItemRemovedFromInventory(playerId, info.itemEntityID, ownedItemId)
        }

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // TODO: Implement, expiring items with item lifetime component
        }

        access(self)
        fun borrowInventory(_ playerId: UInt64): &InventoryComponent.Component {
            let playerEntity = self.borrowEntity(playerId)
            let comp = playerEntity.borrowComponent(Type<@InventoryComponent.Component>())
                ?? panic("Player does not have an inventory")
            return comp as! &InventoryComponent.Component
        }

        access(self)
        fun borrowItem(_ itemId: UInt64): &ItemComponent.Component {
            let itemEntity = self.borrowEntity(itemId)
            let comp = itemEntity.borrowComponent(Type<@ItemComponent.Component>())
                ?? panic("Item does not exist")
            return comp as! &ItemComponent.Component
        }

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
