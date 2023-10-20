import "IComponent"
import "ISystem"

/// The contract interface for the module, which is the basic unit of the
/// application. A module is a collection of systems that provide a specific
/// functionality. A module can be installed in the application and can be used
/// by other modules.
///
pub contract interface IModule {

    pub resource interface Installer {
        /// Returns the name of the module
        ///
        access(all) view
        fun getName(): String

        /// Loads the system factories that are provided by the module.
        ///
        access(all)
        fun loadSystemFactories(): @[AnyResource{ISystem.SystemFactory}]

        /// Loads the component factories that are provided by the module.
        ///
        access(all)
        fun loadComponentFactories(): @[AnyResource{IComponent.ComponentFactory}]
    }

    pub resource Module: Installer  {}

    pub fun createModule(): @Module
}
