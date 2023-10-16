// Third-party imports
import "MetadataViews"

// Owned imports
import "IComponent"

/// The contract interface for the entity resource
///
pub contract interface IEntity {

    /* --- Interfaces & Resources --- */

    /// The public interface for the entity resource
    ///
    pub resource interface EntityPublic {
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
                .concat(self.uuid.toString())
        }
    }

    /// The entity resource
    ///
    pub resource Entity: MetadataViews.Resolver, EntityPublic {
        /* ----- Default implementation of Entity Private */

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

        /// Enables or disables the component of the given type from the entity
        ///
        pub fun setComponentEnabled(_ componentType: Type, _ enabled: Bool)
    }

    /// The create function for the entity resource
    ///
    pub fun create(): @Entity
}
