import "Context"
import "IWorld"
import "ISystem"
import "InventoryComponent"
import "ItemComponent"
import "OwnedItemComponent"

pub contract InventorySystem: ISystem {

    // Events

    pub event ItemAddedToInventory(_ playerId: UInt64, _ itemId: UInt64, _ ownedItemId: UInt64)

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
        fun addItemToInventory(_ playerId: UInt64, _ itemEntityId: UInt64) {
            let playerInventory = self.borrowInventory(playerId)
            let item = self.borrowItem(itemEntityId)

            // create owned item entity
            let world = self.borrowWorld()
            let entity = world.createEntity(nil)

            let entityMgr = world.borrowEntityManager()
            entityMgr.addComponent(Type<@OwnedItemComponent.Component>(), to: entity, withData: nil)
            // TODO update ownedItem data

            let itemInfo = item.toStruct()
            if itemInfo.fungible {
                playerInventory.addFungibleItem(itemEntityId, 1)
            } else {
                playerInventory.addNonFungibleItem(itemEntityId)
            }

            emit ItemAddedToInventory(playerId, itemEntityId, entity.getId())
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
