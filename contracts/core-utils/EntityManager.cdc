import "IEntity"
import "IComponent"

/// The contract that manages the entity system.
///
pub contract EntityManager {

    // Events
    pub event EntityCreated(managerUuid: UInt64, uuid: UInt64)
    pub event ComponentFactoryRegistered(managerUuid: UInt64, type: Type)

    /// The public interface of the entity manager.
    ///
    pub resource interface ManagerPublic {
        access(all)
        fun exists(uuid: UInt64): Bool

        access(all)
        fun getAllEntityPublicRefs(): [&{IEntity.EntityPublic}]
    }

    /// The resource that manages the entities.
    ///
    pub resource Mananger: ManagerPublic {
        access(self)
        let facotry: @IEntity.EntityFactory
        access(self)
        let entities: @{UInt64: IEntity.Entity}
        access(self)
        let componentFactories: {Type: Capability<&AnyResource{IComponent.ComponentFactory}>}

        init(
            factory: @IEntity.EntityFactory,
        ) {
            self.facotry <- factory
            self.entities <- {}
            self.componentFactories = {}
        }

        destroy() {
            destroy self.facotry
            destroy self.entities
        }

        // ---- Public methods  ----

        /// Checks if an entity exists.
        ///
        access(all)
        fun exists(uuid: UInt64): Bool {
            return self.entities.containsKey(uuid)
        }

        /// Gets all the entity public references.
        ///
        access(all)
        fun getAllEntityPublicRefs(): [&{IEntity.EntityPublic}] {
            let refs: [&{IEntity.EntityPublic}] = []
            for key in self.entities.keys {
                if let entity = self.borrowEntity(uuid: key) {
                    refs.append(entity)
                }
            }
            return refs
        }

        // ---- Private methods - for Entities ----

        /// Creates a new entity.
        ///
        access(all)
        fun createEntity(): &IEntity.Entity {
            let entity <- self._createEntity()
            let uuid = entity.uuid
            self.entities[uuid] <-! entity

            emit EntityCreated(
                managerUuid: self.uuid,
                uuid: uuid
            )

            return self.borrowEntity(uuid: uuid)
                ?? panic("Failed to borrow entity")
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

        // ---- Internal methods  ----

        /// Borrows the entity with the given uuid.
        ///
        access(account)
        fun borrowEntity(uuid: UInt64): &IEntity.Entity? {
            return &self.entities[uuid] as &IEntity.Entity?
        }

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
