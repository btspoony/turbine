// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"
import "IEntity"
import "DisplayComponent"

/// The contract interface for the entity resource
///
pub contract BaseEntity: IEntity {

    // Events

    pub event ComponentAdded(uuid: String, _ componentType: Type)
    pub event ComponentRemoved(uuid: String, _ componentType: Type)
    pub event ComponentSet(uuid: String, _ componentType: Type)
    pub event ComponentEnabled(uuid: String, _ componentType: Type, _ enabled: Bool)

    /// The entity resource
    ///
    pub resource Entity: MetadataViews.Resolver, IEntity.EntityPublic {
        /// The components of the entity
        access(self) let components: @{Type: IComponent.Component}
        access(self) let displayType: Type?

        init() {
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
            for k in keys {
                if let ref = self.borrowComponent(k) {
                    if ref.isInstance(Type<&AnyResource{MetadataViews.Resolver}>()) {
                        let anyRef = ref as! &AnyResource{MetadataViews.Resolver}
                        return resolver.getViews()
                    }
                }
            }
            return []
        }

        /// Resolves the given view if supported - none at this time
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            return nil
        }

        /* ----- Default implementation of Entity Public */

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
            self.components[type] <-! component
            self.borrowComponent(type)?.setEnable(true)
        }

        /// Detaches the component of the given type from the entity
        ///
        pub fun removeComponent(_ componentType: Type): @IComponent.Component {
            let comp <- (self.components.remove(key: componentType)
                ?? panic("This component is not attached to entity"))
            comp.setEnable(false)
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
            }
        }
    }
}
