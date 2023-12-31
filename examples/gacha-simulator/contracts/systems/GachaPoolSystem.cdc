import "Context"
import "IWorld"
import "ISystem"
import "IEntity"
import "EntityQuery"
import "ItemComponent"
import "GachaPoolComponent"
import "InventoryComponent"

pub contract GachaPoolSystem: ISystem {

    // Events
    pub event GachaPoolAdded(_ entityId: UInt64, name: String)
    pub event GachaPoolItemAdded(_ entityId: UInt64, name: String, item: UInt64, probability: UFix64)
    pub event GachaPoolItemsAdded(_ entityId: UInt64, name: String, items: [UInt64])
    pub event GachaPoolBoostingItemsSet(_ entityId: UInt64, name: String, items: [UInt64])
    pub event GachaPoolCounterSet(_ entityId: UInt64, name: String, threshold: UInt64, mod: UFix64)

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
        fun createNewGachaPoolEntity(_ name: String): UInt64 {
            let world = self.borrowWorld()
            let existing = self.findGachaPoolEntity(name: name)
            assert(existing == nil, message: "Already exists: Gacha pool - ".concat(name))

            let entity = world.createEntity(nil)

            let entityMgr = world.borrowEntityManager()
            let compType = Type<@GachaPoolComponent.Component>()
            entityMgr.addComponent(
                compType,
                to: entity,
                withData: { "name": name }
            )
            emit GachaPoolAdded(entity.getId(), name: name)

            // set the component to disabled by default
            entity.setComponentEnabled(compType, false)

            return entity.getId()
        }

        /// Query all gacha pools
        ///
        access(all)
        fun queryGachaPools(): [&GachaPoolComponent.Component] {
            let world = self.borrowWorld()

            let compType = Type<@GachaPoolComponent.Component>()
            let query = EntityQuery.Builder()
            query.withAll(types: [compType])

            let entities = query.executeQuery(world)
            let ret: [&GachaPoolComponent.Component] = []
            for entity in entities {
                if let comp = entity.borrowComponent(compType) {
                    ret.append(comp as! &GachaPoolComponent.Component)
                }
            }
            return ret
        }

        access(all)
        fun findGachaPoolEntity(name: String): &IEntity.Entity? {
            let world = self.borrowWorld()

            let query = EntityQuery.Builder()
            let compType = Type<@GachaPoolComponent.Component>()
            query.withAll(types: [compType])

            let entities = query.executeQuery(world)
            var found: &IEntity.Entity? = nil
            for entity in entities {
                if let comp = entity.borrowComponent(compType) {
                    let poolName = (comp as! &GachaPoolComponent.Component).getName()
                    log("Found Pool name: ".concat(poolName))
                    if poolName == name {
                        found = entity
                        break
                    }
                }
            }
            return found
        }

        /// Add an item to the pool
        ///
        access(all)
        fun addItemToPool(_ poolEntityId: UInt64, itemEntityId: UInt64, probability: UFix64) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.addItem(itemEntityId, probability)

            emit GachaPoolItemAdded(
                poolEntityId,
                name: comp.getName(),
                item: itemEntityId,
                probability: probability
            )
        }

        /// Addd multiple items to the pool
        ///
        access(all)
        fun addItemsToPool(_ poolEntityId: UInt64, itemEntityIds: [UInt64]) {
            let comp = self.borrowGachaPool(poolEntityId)
            let itemDic: {UInt64: UFix64} = {}
            for id in itemEntityIds {
                itemDic[id] = 0.0
            }
            comp.addItems(items: itemDic)

            emit GachaPoolItemsAdded(
                poolEntityId,
                name: comp.getName(),
                items: itemEntityIds
            )
        }

        /// Set the rare probability pool
        ///
        access(all)
        fun setRareProbabilityPool(_ poolEntityId: UInt64, _ probPool: {UInt8: UFix64}) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.setRareProbabilityPool(pool: probPool)
        }

        access(all)
        fun setBoostingProbabilityItems(_ poolEntityId: UInt64, itemEntities: [UInt64], probability: UFix64) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.setBoostingProbabilityItems(itemEntities, probability)

            emit GachaPoolBoostingItemsSet(
                poolEntityId,
                name: comp.getName(),
                items: itemEntities
            )
        }

        access(all)
        fun setGachaCounter(_ poolEntityId: UInt64, threshold: UInt64, probabilityMod: UFix64) {
            let comp = self.borrowGachaPool(poolEntityId)
            comp.setCounterModifier(threshold, probabilityMod)

            emit GachaPoolCounterSet(
                poolEntityId,
                name: comp.getName(),
                threshold: threshold,
                mod: probabilityMod
            )
        }

        access(all)
        fun setGachaPoolEnabled(_ poolEntityId: UInt64, enabled: Bool) {
            let entity = self.borrowEntity(poolEntityId)
            entity.setComponentEnabled(Type<@GachaPoolComponent.Component>(), enabled)
        }

        /// Borrow the gacha pool component
        ///
        access(all)
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
