import "Context"
import "IWorld"
import "ISystem"
import "EntityQuery"
import "IdentityComponent"
import "PlayerComponent"
import "InventoryComponent"

pub contract PlayerRegSystem: ISystem {

    // Events
    pub event PlayerRegistered(_ playerId: UInt64, username: String)

    pub resource System: ISystem.CoreLifecycle, Context.Consumer {
        access(contract)
        let worldCap: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        access(contract)
        var enabled: Bool

        init(
            _ world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ) {
            self.worldCap = world
            self.enabled = true
        }

        /// Query the player by username
        ///
        access(all)
        fun queryPlayerByUsername(_ username: String): UInt64? {
            let query = EntityQuery.Builder()
            query.withAll(types: [
                Type<@IdentityComponent.Component>(),
                Type<@PlayerComponent.Component>(),
                Type<@InventoryComponent.Component>()
            ])
            let entities = query.executeQuery(self.borrowProvider())
            for entity in entities {
                if let comp = entity.borrowComponent(Type<@IdentityComponent.Component>()) {
                    let identity = comp as! &IdentityComponent.Component
                    if identity.getUsername() == username {
                        return entity.getId()
                    }
                }
            }
            return nil
        }

        access(all)
        fun fetchOrRegisterPlayer(_ username: String): UInt64 {
            // For the player already exists
            if let existing = self.queryPlayerByUsername(username){
                return existing
            }

            // Create the player
            let world = self.borrowWorld()
            let player = world.createEntity(nil)

            let entityMgr = world.borrowEntityManager()
            entityMgr.addComponent(Type<@IdentityComponent.Component>(), to: player, withData: {
                "username": username
            })
            entityMgr.addComponent(Type<@PlayerComponent.Component>(), to: player, withData: nil)
            entityMgr.addComponent(Type<@InventoryComponent.Component>(), to: player, withData: nil)

            emit PlayerRegistered(player.getId(), username: username)

            return player.getId()
        }

        /// System event callback to add the work that your system must perform every frame.
        ///
        access(all)
        fun onUpdate(_ dt: UFix64): Void {
            // NOTHING
        }
    }

    /// The system factory resource
    ///
    pub resource SystemFactory: ISystem.SystemFactory {
        /// Creates a new system
        ///
        pub fun create(
            world: Capability<&AnyResource{Context.Provider, IWorld.WorldState}>
        ): @System {
            return <- create System(world)
        }

        /// Returns the type of the system
        ///
        pub fun instanceType(): Type {
            return Type<@System>()
        }
    }

    /// The create function for the system factory resource
    ///
    pub fun createFactory(): @SystemFactory {
        return <- create SystemFactory()
    }
}
