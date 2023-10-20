// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

/// The contract interface for the entity resource, which is the core of the
/// ECS system. It is a container for components, which are the data of the
/// system. The entity is also identified by a UUID, which is a random number
/// generated when the entity is created.
///
pub contract interface IEntity {

    /* --- Interfaces & Resources --- */

    /// The public interface for the entity resource
    ///
    pub resource interface EntityPublic {
        /// Returns the entity uid
        pub fun getId(): UInt64

        /// Return owner address
        pub fun getOwnerAddress(): Address {
            return self.owner?.address ?? panic("Invalid owner address")
        }
        /// Returns true if the component exists
        pub fun hasComponent(_ type: Type): Bool

        /// Returns the components' types
        pub fun getComponetKeys(): [Type]

        /// Returns the entity identitier string
        pub fun toString(): String {
            return "Address<"
                .concat(self.getOwnerAddress().toString())
                .concat("> Entity[")
                .concat(self.getType().identifier)
                .concat("]:")
                .concat(self.getId().toString())
        }
    }

    /// The entity resource
    ///
    pub resource Entity: MetadataViews.Resolver, EntityPublic {
        /// --- Query functions ---

        /// Iterates over all components
        ///
        pub fun forEachComponents(_ callback: ((Type, &IComponent.Component): Void)) {
            for componentType in self.getComponetKeys() {
                if let component = self.borrowComponent(componentType) {
                    callback(componentType, component)
                }
            }
        }

        /// --- Default implementation of Entity Private ---

        /// Attaches the given component to the entity
        ///
        pub fun addComponent(_ component: @IComponent.Component)

        /// Detaches the component of the given type from the entity
        ///
        pub fun removeComponent(_ componentType: Type): @IComponent.Component

        /// overwrites the component of the given type from the entity
        ///
        pub fun setComponent(_ component: @IComponent.Component): @IComponent.Component?

        /// Borrows the component of the given type from the entity
        ///
        pub fun borrowComponent(_ componentType: Type): auth &IComponent.Component?

        /// --- Enablement Methods ---

        /// Enables or disables the component of the given type from the entity
        ///
        pub fun setComponentEnabled(_ componentType: Type, _ enabled: Bool)

        /// Enables or disables all components from the entity
        ///
        pub fun setComponentsEnabled(_ enabled: Bool) {
            for componentType in self.getComponetKeys() {
                self.setComponentEnabled(componentType, enabled)
            }
        }
    }

    /// The entity factory resource
    ///
    pub resource EntityFactory {
        /// Creates a new entity
        ///
        pub fun create(_ uid: UInt64?): @Entity
    }

    /// The create function for the entity factory resource
    ///
    access(account) fun createFactory(): @EntityFactory
}
