import "Context"
import "IWorld"
import "ISystem"
import "IEntity"
import "ItemComponent"
import "GachaPoolComponent"
import "InventoryComponent"

pub contract GachaPoolSystem: ISystem {

    // Events
    pub event GachaPoolAdded(_ entityId: UInt64)
    pub event GachaPoolItemAdded(_ entityId: UInt64, _ itemEntityId: UInt64, probability: UFix64)
    pub event GachaPoolBoostingItemsSet(_ entityId: UInt64, _ itemEntities: [UInt64])
    pub event GachaPoolCounterSet(_ entityId: UInt64, _ threshold: UInt64, _ probabilityMods: [UFix64])

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
        fun createNewGachaPoolEntity(): UInt64 {
            let world = self.borrowWorld()
            let entity = world.createEntity(nil)

            emit GachaPoolAdded(entity.getId())

            let entityMgr = world.borrowEntityManager()
            let compType = Type<@GachaPoolComponent.Component>()
            entityMgr.addComponent(
                compType,
                to: entity,
                withData: nil
            )
            // set the component to disabled by default
            entity.setComponentEnabled(compType, false)

            return entity.getId()
        }

        access(all)
        fun addItemToPool(_ poolEntityId: UInt64, itemEntityId: UInt64, probability: UFix64) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.addItem(itemEntityId, probability)

            emit GachaPoolItemAdded(poolEntityId, itemEntityId, probability: probability)
        }

        access(all)
        fun setBoostingProbabilityItems(_ poolEntityId: UInt64, itemEntities: [UInt64]) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.setBoostingProbabilityItems(itemEntities)

            emit GachaPoolBoostingItemsSet(poolEntityId, itemEntities)
        }

        access(all)
        fun setGachaCounter(_ poolEntityId: UInt64, threshold: UInt64, probabilityMods: [UFix64]) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.setCounterModifier(threshold, probabilityMods)

            emit GachaPoolCounterSet(poolEntityId, threshold, probabilityMods)
        }

        access(all)
        fun setGachaPoolEnabled(_ poolEntityId: UInt64, enabled: Bool) {
            let entity = self.borrowEntity(poolEntityId)
            entity.setComponentEnabled(Type<@GachaPoolComponent.Component>(), enabled)
        }

        /// Borrow the gacha pool component
        ///
        access(self)
        fun borrowGachaPool(_ poolEntityId: UInt64): &GachaPoolComponent.Component {
            let poolEntity = self.borrowEntity(poolEntityId)
            let comp = poolEntity.borrowComponent(Type<@GachaPoolComponent.Component>())
                ?? panic("Pool component not found in Entity:".concat(poolEntityId.toString()))
            return comp as! &GachaPoolComponent.Component
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
