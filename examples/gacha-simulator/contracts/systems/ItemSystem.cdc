import "Context"
import "IWorld"
import "ISystem"
import "MetadataViews"
import "DisplayComponent"
import "ItemComponent"
import "EntityQuery"

pub contract ItemSystem: ISystem {

    // Events
    pub event ItemAdded(_ entityId: UInt64)

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
        fun listItems(): {UInt64: ItemComponent.ItemInfo} {
            let world = self.borrowWorld()

            let query = EntityQuery.Builder()
            query.withAll(types: [Type<@ItemComponent.Component>()])
            let entities = query.executeQuery(self.borrowProvider())

            let items: {UInt64: ItemComponent.ItemInfo} = {}
            for entity in entities {
                if let comp = entity.borrowComponent(Type<@ItemComponent.Component>()) {
                    items[entity.getId()] = (comp as! &ItemComponent.Component).toStruct()
                }
            }
            return items
        }

        access(all)
        fun addItemEntity(itemInfo: ItemComponent.ItemInfo, display: MetadataViews.Display?): UInt64 {
            let world = self.borrowWorld()
            let entityMgr = world.borrowEntityManager()

            // create new entity to the world
            let newEntity = world.createEntity(nil)

            emit ItemAdded(newEntity.getId())

            // add item component
            entityMgr.addComponent(
                Type<@ItemComponent.Component>(),
                to: newEntity,
                withData: itemInfo.toDictionary()
            )
            if display == nil {
                return newEntity.getId()
            }
            // add display component
            let displayData: {String: AnyStruct} = {
                "name": display!.name,
                "description": display!.description,
                "thumbnail": display!.thumbnail.uri()
            }
            entityMgr.addComponent(
                Type<@DisplayComponent.Component>(),
                to: newEntity,
                withData: displayData
            )
            return newEntity.getId()
        }

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // NOTHING
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
