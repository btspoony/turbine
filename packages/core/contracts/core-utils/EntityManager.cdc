import "IEntity"
import "IComponent"
import "Context"
import "EntityQuery"

/// The contract that manages the entity system.
///
pub contract EntityManager {

    // Events
    pub event EntityCreated(managerUuid: UInt64, id: UInt64)
    pub event ComponentFactoryRegistered(managerUuid: UInt64, type: Type)
    pub event ComponentAdded(managerUuid: UInt64, entity: UInt64, type: Type)

    /// The resource that manages the entities.
    ///
    pub resource Manager {
        access(self)
        let facotry: @IEntity.EntityFactory
        access(self)
        let componentFactories: {Type: Capability<&AnyResource{IComponent.ComponentFactory}>}

        init(
            _ factory: @IEntity.EntityFactory,
        ) {
            self.facotry <- factory
            self.componentFactories = {}
        }

        destroy() {
            destroy self.facotry
        }

        // ---- Private methods - for Entities ----

        /// Creates a new entity.
        ///
        access(all)
        fun createEntity(_ uid: UInt64?): @IEntity.Entity {
            let entity <- self._createEntity(uid)

            emit EntityCreated(
                managerUuid: self.uuid,
                id: entity.getId()
            )

            return <- entity
        }

        // ---- Private methods - for Components ----

        /// Registers a component factory.
        ///
        access(all)
        fun registerCompenentFactory(
            factory: Capability<&AnyResource{IComponent.ComponentFactory}>,
        ) {
            pre {
                factory.check(): "Component factory is not valid"
            }
            let ref = factory.borrow() ?? panic("Failed to borrow component factory")
            let compType = ref.instanceType()

            assert(!self.componentFactories.containsKey(compType), message: "Component factory already registered")

            self.componentFactories[compType] = factory

            emit ComponentFactoryRegistered(
                managerUuid: self.uuid,
                type: compType
            )
        }

        /// Returns all registered component types.
        ///
        access(all)
        fun registeredComponents(): [Type] {
            return self.componentFactories.keys
        }

        /// Adds a component to an entity.
        ///
        access(all)
        fun addComponent(_ compType: Type, to: &IEntity.Entity, withData: {String: AnyStruct}?) {
            pre {
                self.componentFactories.containsKey(compType): "Not registered component factory: ".concat(compType.identifier)
            }
            let compFtyCap = self.componentFactories[compType] ?? panic("Failed to get component factory")
            let compFty = compFtyCap.borrow() ?? panic("Failed to borrow component factory")
            to.addComponent(<- compFty.create())

            // Set data if any
            if let data = withData {
                let compRef = to.borrowComponent(compType) ?? panic("Failed to borrow component")
                compRef.setData(data)
            }

            emit ComponentAdded(
                managerUuid: self.uuid,
                entity: to.getId(),
                type: compType
            )
        }

        /// Adds a component to entities.
        ///
        access(all)
        fun addComponentBatch(
            _ compType: Type,
            to: EntityQuery.Builder,
            ctx: &AnyResource{Context.Provider},
        ) {
            pre {
                self.componentFactories.containsKey(compType): "Component factory not registered"
            }
            let compFtyCap = self.componentFactories[compType] ?? panic("Failed to get component factory")
            let compFty = compFtyCap.borrow() ?? panic("Failed to borrow component factory")

            let entities = to.executeQuery(ctx)
            for entity in entities {
                entity.addComponent(<- compFty.create())

                emit ComponentAdded(
                    managerUuid: self.uuid,
                    entity: entity.getId(),
                    type: compType
                )
            }
        }

        // ---- Internal methods  ----

        /// Creates a new entity.
        ///
        access(self)
        fun _createEntity(_ uid: UInt64?): @IEntity.Entity {
            let facotry = &self.facotry as &IEntity.EntityFactory
            return <- facotry.create(uid)
        }
    }

    /// Creates a new manager.
    ///
    pub fun create(
        factory: @IEntity.EntityFactory,
    ): @Manager {
        return <- create Manager(<- factory)
    }
}
