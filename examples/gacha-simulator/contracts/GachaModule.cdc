import "IComponent"
import "ISystem"
import "IModule"
import "GachaPoolComponent"
import "IdentityComponent"
import "InventoryComponent"
import "ItemComponent"
import "OwnedItemComponent"
import "PlayerComponent"
import "GachaGameSystem"
import "GachaPoolSystem"
import "InventorySystem"
import "ItemSystem"
import "PlayerRegSystem"

pub contract GachaModule: IModule {

    pub resource Module: IModule.Installer  {

        /// Returns the name of the module
        ///
        access(all) view
        fun getName(): String {
            return "GachaSimulatorGame"
        }

        /// Loads the system factories that are provided by the module.
        ///
        access(all)
        fun loadSystemFactories(): @[AnyResource{ISystem.SystemFactory}] {
            let ret: @[AnyResource{ISystem.SystemFactory}] <- []
            ret.append(<- GachaGameSystem.createFactory())
            ret.append(<- GachaPoolSystem.createFactory())
            ret.append(<- InventorySystem.createFactory())
            ret.append(<- ItemSystem.createFactory())
            ret.append(<- PlayerRegSystem.createFactory())
            return <- ret
        }

        /// Loads the component factories that are provided by the module.
        ///
        access(all)
        fun loadComponentFactories(): @[AnyResource{IComponent.ComponentFactory}] {
            let ret: @[AnyResource{IComponent.ComponentFactory}] <- []
            ret.append(<- GachaPoolComponent.createFactory())
            ret.append(<- IdentityComponent.createFactory())
            ret.append(<- InventoryComponent.createFactory())
            ret.append(<- ItemComponent.createFactory())
            ret.append(<- OwnedItemComponent.createFactory())
            ret.append(<- PlayerComponent.createFactory())
            return <- ret
        }
    }

    pub fun createModule(): @Module {
        return <- create Module()
    }
}
