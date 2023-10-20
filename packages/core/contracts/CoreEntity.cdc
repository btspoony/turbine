// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"
import "IEntity"
import "DisplayComponent"

/// The contract interface for the entity resource
///
pub contract CoreEntity: IEntity {

    // Events

    pub event ComponentAdded(uuid: UInt64, _ componentType: Type)
    pub event ComponentRemoved(uuid: UInt64, _ componentType: Type)
    pub event ComponentSet(uuid: UInt64, _ componentType: Type)
    pub event ComponentEnabled(uuid: UInt64, _ componentType: Type, _ enabled: Bool)

    /// The entity resource
    ///
    pub resource Entity: MetadataViews.Resolver, IEntity.EntityPublic {
        access(self) let id: UInt64
        /// The components of the entity
        access(self) let components: @{Type: IComponent.Component}
        access(self) var displayType: Type?

        init(_ uid: UInt64?) {
            self.id = uid ?? self.uuid
            self.components <- {}
            self.displayType = nil
        }

        destroy() {
            destroy self.components
        }

        /* ---- Default implemation of MetadataViews.Resolver ---- */

        /// Returns the types of supported views - none at this time
        ///
        pub fun getViews(): [Type] {
            let keys = self.components.keys
            // cached display type
            if let k = self.displayType {
                if let ref = self.borrowComponent(k) {
                    if ref.isInstance(Type<&DisplayComponent.Component>()) {
                        let anyRef = ref as! &DisplayComponent.Component
                        return anyRef.getViews()
                    }
                }
            }
            // search for display type
            for k in keys {
                if let ref = self.borrowComponent(k) {
                    if ref.isInstance(Type<&DisplayComponent.Component>()) {
                        let anyRef = ref as! &DisplayComponent.Component
                        return anyRef.getViews()
                    }
                }
            }
            return []
        }

        /// Resolves the given view if supported - none at this time
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            // cached display type
            if let k = self.displayType {
                if let ref = self.borrowComponent(k) {
                    if ref.isInstance(Type<&DisplayComponent.Component>()) {
                        let anyRef = ref as! &DisplayComponent.Component
                        return anyRef.resolveView(view)
                    }
                }
            }
            // search for display type
            let keys = self.components.keys
            for k in keys {
                if let ref = self.borrowComponent(k) {
                    if ref.isInstance(Type<&DisplayComponent.Component>()) {
                        let anyRef = ref as! &DisplayComponent.Component
                        return anyRef.resolveView(view)
                    }
                }
            }
            return nil
        }

        /* ----- Default implementation of Entity Public */

        /// Returns the entity uid
        pub fun getId(): UInt64 {
            return self.id
        }

        /// Returns true if the entity has a component of the given type
        ///
        pub fun hasComponent(_ type: Type): Bool {
            return self.components.containsKey(type)
        }

        /// Returns the components' types
        ///
        pub fun getComponetKeys(): [Type] {
            return self.components.keys
        }

        /* ----- Default implementation of Entity Private */

        /// Attaches the given component to the entity
        ///
        pub fun addComponent(_ component: @IComponent.Component) {
            let type = component.getType()
            assert(
                self.components[type] == nil,
                message: "This component already attached to entity"
            )

            // check if this is a display component
            if component.isInstance(Type<&DisplayComponent.Component>()) {
                self.displayType = type
            }

            self.components[type] <-! component
            self.borrowComponent(type)?.setEnable(true)

            emit ComponentAdded(
                uuid: self.uuid,
                type
            )
        }

        /// Detaches the component of the given type from the entity
        ///
        pub fun removeComponent(_ componentType: Type): @IComponent.Component {
            let comp <- (self.components.remove(key: componentType)
                ?? panic("This component is not attached to entity"))
            comp.setEnable(false)

            emit ComponentRemoved(
                uuid: self.uuid,
                componentType
            )
            return <- comp
        }

        /// overwrites the component of the given type from the entity
        ///
        pub fun setComponent(_ component: @IComponent.Component): @IComponent.Component? {
            let type = component.getType()
            var oldComp: @IComponent.Component? <- nil
            if self.hasComponent(type) {
                oldComp <-! self.removeComponent(type)
            }
            self.addComponent(<-component)

            emit ComponentSet(
                uuid: self.uuid,
                type
            )
            return <- oldComp
        }

        /// Borrows the component of the given type from the entity
        ///
        pub fun borrowComponent(_ componentType: Type): auth &IComponent.Component? {
            return &self.components[componentType] as auth &IComponent.Component?
        }

        /// Enables or disables the component of the given type from the entity
        ///
        pub fun setComponentEnabled(_ componentType: Type, _ enabled: Bool) {
            if let ref = self.borrowComponent(componentType) {
                ref.setEnable(enabled)

                emit ComponentEnabled(
                    uuid: self.uuid,
                    componentType,
                    enabled
                )
            }
        }
    }

    /// The entity factory resource
    ///
    pub resource EntityFactory {
        /// Creates a new entity
        ///
        pub fun create(_ uid: UInt64?): @IEntity.Entity {
            return <- create Entity(uid)
        }
    }

    /// The create function for the entity factory resource
    ///
    access(account) fun createFactory(): @EntityFactory {
        return <- create EntityFactory()
    }
}
