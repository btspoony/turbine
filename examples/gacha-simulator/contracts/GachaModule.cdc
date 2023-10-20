import "IComponent"
import "ISystem"
import "IModule"

pub contract GachaModule: IModule {

    pub resource Module: IModule.Installer  {
        init() {

        }

        /// Returns the name of the module
        ///
        access(all) view
        fun getName(): String {
            return "GachaWorldModule"
        }

        /// Loads the system factories that are provided by the module.
        ///
        access(all)
        fun loadSystemFactories(): @[AnyResource{ISystem.SystemFactory}] {
            let ret: @[AnyResource{ISystem.SystemFactory}] <- []
            // TODO: add system factories
            return <- ret
        }

        /// Loads the component factories that are provided by the module.
        ///
        access(all)
        fun loadComponentFactories(): @[AnyResource{IComponent.ComponentFactory}] {
            let ret: @[AnyResource{IComponent.ComponentFactory}] <- []
            // TODO: add component factories
            return <- ret
        }
    }

    pub fun createModule(): @Module {
        return <- create Module()
    }
}
