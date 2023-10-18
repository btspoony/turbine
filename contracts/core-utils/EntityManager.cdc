import "IEntity"
import "IComponent"

/// The contract that manages the entity system.
///
pub contract EntityManager {

    // Events
    pub event EntityCreated(managerUuid: UInt64, uuid: UInt64)
    pub event ComponentFactoryRegistered(managerUuid: UInt64, type: Type)
    pub event ComponentAdded(managerUuid: UInt64, uuid: UInt64, type: Type)

    /// The resource that manages the entities.
    ///
    pub resource Mananger {
        access(self)
        let facotry: @IEntity.EntityFactory
        access(self)
        let componentFactories: {Type: Capability<&AnyResource{IComponent.ComponentFactory}>}

        init(
            factory: @IEntity.EntityFactory,
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
        fun createEntity(): @IEntity.Entity {
            let entity <- self._createEntity()
            let uuid = entity.uuid

            emit EntityCreated(
                managerUuid: self.uuid,
                uuid: uuid
            )

            return <- entity
        }

        // ---- Private methods - for Components ----

        access(all)
        fun registerCompenentFactory(
            compFty: Capability<&AnyResource{IComponent.ComponentFactory}>,
        ) {
            pre {
                compFty.check(): "Component factory is not valid"
            }
            let ref = compFty.borrow() ?? panic("Failed to borrow component factory")
            let compType = ref.instanceType()

            assert(!self.componentFactories.containsKey(compType), message: "Component factory already registered")

            self.componentFactories[compType] = compFty

            emit ComponentFactoryRegistered(
                managerUuid: self.uuid,
                type: compType
            )
        }

        access(all)
        fun addComponent(_ compType: Type, to: &IEntity.Entity) {
            pre {
                self.componentFactories.containsKey(compType): "Component factory not registered"
            }
            let compFtyCap = self.componentFactories[compType] ?? panic("Failed to get component factory")
            let compFty = compFtyCap.borrow() ?? panic("Failed to borrow component factory")
            to.addComponent(<- compFty.create())

            emit ComponentAdded(
                managerUuid: self.uuid,
                uuid: to.uuid,
                type: compType
            )
        }

        // ---- Internal methods  ----

        /// Creates a new entity.
        ///
        access(self)
        fun _createEntity(): @IEntity.Entity {
            let facotry = &self.facotry as &IEntity.EntityFactory
            return <- facotry.create()
        }
    }

    init() {
        // NOTHING
    }
}
