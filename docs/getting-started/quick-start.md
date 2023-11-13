# Quick Start

_You can check out_ [..](../ "mention") _to learn more about the Turbine before beginning._

In this guide, you will create your first Turbine project and gain an understanding of its structure and ECS game development design pattern.

Before we begin let's make sure your local environment is set up with the proper prerequisites.

## Prerequisites

1. git ([installation](https://git-scm.com/downloads))
2. flow-cli ([installation](https://developers.flow.com/tools/flow-cli/install))
3. node.js(v16+) ([installation](https://nodejs.org/en/download/))
4. pnpm ([installation](https://pnpm.io/installation))

## Setup

### Setup with an empty project

First, we need to use Flow Super Commands `flow setup` to initialize an empty project. By default, it will create the basic folder structure and a flow.json configuration.

Running the command:

{% code lineNumbers="true" %}
```bash
> flow setup my-project
```
{% endcode %}

The folder structure created is this:

```
/my-project
|- /cadence
    |- /contracts // folder should contain all your Cadence contracts
    |- /scripts // folder should contain all your Cadence scripts
    |- /transactions // folder should contain all your Cadence transactions
    |- /tests // folder should contain all your Cadence tests,
|- flow.json // is a configuration file for your project
|- README.md
```

Now, you can install Turbine's core library.

Running the command to create a `package.json` and add core library of Turbine to the project.

{% code lineNumbers="true" %}
```bash
pnpm init
pnpm add @turbine-cdc/core
```
{% endcode %}

To facilitate future development and usage, you can update the `package.json` file with the following fields:

{% code lineNumbers="true" %}
```json
{
"exports": {
    "./contracts/*": "./contracts/*.cdc",
    "./transactions/*": "./transactions/*.cdc",
    "./scripts/*": "./scripts/*.cdc",
    "./flow.json": "./flow.json"
  },
  "scripts": {
    "deploy:emulator": "flow project deploy --update",
    "deploy:testnet": "flow project deploy --update --network testnet",
    "deploy:mainnet": "flow project deploy --update --network mainnet",
    "dev": "pnpm deploy:emulator"
  }
}
```
{% endcode %}

Currently, you have installed the core contract library of Turbine. Now you need to add those contracts to your project's `flow.json` file.

Update your `flow.json` file to add the following data to the proper fields:

{% code lineNumbers="true" %}
```json
{
  "contracts": {
    "CapabilityComponent": {
      "source": "./node_modules/@turbine-cdc/core/contracts/components/CapabilityComponent.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "Context": {
      "source": "./node_modules/@turbine-cdc/core/contracts/core-utils/Context.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "CoreEntity": {
      "source": "./node_modules/@turbine-cdc/core/contracts/CoreEntity.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "CoreWorld": {
      "source": "./node_modules/@turbine-cdc/core/contracts/CoreWorld.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "DisplayComponent": {
      "source": "./node_modules/@turbine-cdc/core/contracts/components/DisplayComponent.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "EntityManager": {
      "source": "./node_modules/@turbine-cdc/core/contracts/core-utils/EntityManager.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "EntityQuery": {
      "source": "./node_modules/@turbine-cdc/core/contracts/core-utils/EntityQuery.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "IComponent": {
      "source": "./node_modules/@turbine-cdc/core/contracts/interfaces/IComponent.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "IEntity": {
      "source": "./node_modules/@turbine-cdc/core/contracts/interfaces/IEntity.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "IModule": {
      "source": "./node_modules/@turbine-cdc/core/contracts/interfaces/IModule.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "ISystem": {
      "source": "./node_modules/@turbine-cdc/core/contracts/interfaces/ISystem.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "IWorld": {
      "source": "./node_modules/@turbine-cdc/core/contracts/interfaces/IWorld.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "PropertyComponent": {
      "source": "./node_modules/@turbine-cdc/core/contracts/components/PropertyComponent.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    },
    "WorldUtils": {
      "source": "./node_modules/@turbine-cdc/core/contracts/core-utils/WorldUtils.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "3102c5131b585d67"
      }
    }
  }
  "deployments": {
    "emulator": {
      "emulator-account": [
        "Context",
        "IComponent",
        "IEntity",
        "ISystem",
        "IModule",
        "IWorld",
        "EntityQuery",
        "EntityManager",
        "DisplayComponent",
        "PropertyComponent",
        "CapabilityComponent",
        "CoreEntity",
        "CoreWorld",
        "WorldUtils"
      ]
    }
  }
}
```
{% endcode %}

Now you have completed the installation of the Turbine Framework core library.&#x20;

Let's start building an FOC game!

### Setup using Turbine scaffold

> _Working in progress_

#### Recommended structure of the Contracts folder

In order to facilitate project maintenance, we recommend organizing the contracts directory in the following way:

```
/contracts
|- /components // folder should contain all your component contracts.
|- /system // folder should contain all your system contracts.
|- MyModule.cdc // will import all components and systems for registration.
|- MyPlatform.cdc // (Optional) is used to centrally manage the worlds.
```

## Build

### Components in Turbine

> Component is the actual carrier of data in Entity. [Learn more](../#what-is-ecs-architecture)

All components in the Turbine must implement the `IComponent` contract interface. You should not implement any business logic in the Component. It should only define data structures or handle data reading and writing.

Here is an example:

{% code lineNumbers="true" %}
```swift
import "IComponent"

pub contract CounterComponent: IComponent {

    /// Events
    
    // Your Code: Events

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        init() {
            self.enabled = true
            self.kv = {}
            /// Your code: setup default key values
            self.kv["counter"] = 0 as UInt64
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                // Your code: all valid keys
                "counter"
            ]
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct}): Void {
            // Your code: how to store the data
            if kv["counter"] != nil {
                self.kv["counter"] = kv["counter"] as! UInt64? ?? panic("Invalid counter")
            }
        }

        /// --- Component Specific methods ---
        
        // Your code: read and write methods

        /// Sets countter
        ///
        access(all)
        fun getCounter(): UInt64 {
            return self.kv["counter"] as! UInt64? ?? panic("Invalid counter")
        }
        
        access(all)
        fun increment(amount: UInt64) {
            let currentValue = self.getCounter()
            self.setData({ "counter": currentValue + amount })
        }
    }

    /// The component factory resource
    ///
    pub resource Factory: IComponent.ComponentFactory {
        /// The create function for the component factory resource
        ///
        pub fun create(): @Component {
            return <- create Component()
        }

        /// Returns the type of the component
        ///
        pub fun instanceType(): Type {
            return Type<@Component>()
        }
    }

    /// The create function for the entity factory resource
    ///
    pub fun createFactory(): @Factory {
        return <- create Factory()
    }
}
```
{% endcode %}

### Systems in Turbine

> Turbine was built with a complete separation of **data** (via components) and **logic** (the stateless contracts). These stateless pieces of logic are what we call **systems** in Turbine. [Learn more](../#what-is-ecs-architecture)

In the previous Component section, we created a `CounterComponent`. Now we can create an `IncrementSystem.cdc` to operate on that component.

Before that, let's introduce a utility library called `EntityQuery.cdc`.

#### EntityQuery - the way to query entities from the systems

In the core library, there is a dedicated tool contract for searching entities. It mainly refers to the design of Entity querying in Unity.

The contract contains a `Builder` Struct, you can perform queries on entities through that.

{% code lineNumbers="true" %}
```swift
import "EntityQuery"

let query = EntityQuery.Builder()
query.withAll(types: [
    Type<@CounterComponent.Component>()
])
// Execute Query requires a world context which will be introduced in the next section
let entities = query.executeQuery(world)
```
{% endcode %}

Now we can create the `IncrementSystem.cdc`.

{% code lineNumbers="true" %}
```swift
import "Context"
import "IWorld"
import "ISystem"
import "EntityQuery"
import "IdentityComponent"

pub contract IncrementSystem: ISystem {

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
        fun incrementAll(amount: UInt64) {
            let query = EntityQuery.Builder()
            query.withAll(types: [
                Type<@CounterComponent.Component>()
            ])
            let world = self.borrowWorld()
            let entities = query.executeQuery(world)
            for entity in entities {
                if let comp = entity.borrowComponent(Type<@CounterComponent.Component>()) {
                    let counter = comp as! &CounterComponent.Component
                    counter.increment(amount: amount)
                }
            }
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
```
{% endcode %}

When calling the `incrementAll` method of System, it will find all Entities in World that contain `CounterComponent` and call their `increment` method to modify the values.

What needs to be noted here is that each System can have an `onUpdate` method. This method will be synchronously called when the `update` method of the world is called. If there is a need to implement some logic that changes over time, it can be written inside the `onUpdate` method.

### World in Turbine

> World is the **context** of the game, and the resource contains all `entities` and `systems` resources for the game

You don't need to implement another World contract anymore, because Turbine has already provided a standard implementation of World called `CoreWorld`.

So you need to have a resource of `CoreWorld`'s WorldManager to initialize your game world.

{% code lineNumbers="true" %}
```swift
import "CoreWorld"

/// Create a new game world
access(all)
fun createWorld(
    _ admin: Capability<&AuthAccount>,
    name: String
) {
    // Borrow the admin account
    let acct = admin.borrow() ?? panic("Could not borrow admin account")

    // Fetch or create the world manager
    var worldMgr: &CoreWorld.WorldManager? = nil
    if !CoreWorld.hasManager(acct: acct.address) {
        worldMgr = CoreWorld.createManager(admin: admin)
    } else {
        worldMgr = acct.borrow<&CoreWorld.WorldManager>(from: CoreWorld.WorldManagerStoragePath)
    }
    assert(worldMgr != nil, message: "Could not borrow world manager")
    
    // Create the world. The second parameter can also accept a list of System's types.
    // This is used to perform the initialization of System during creation.
    let world = worldMgr!.create(name, withSystems: [])
}
```
{% endcode %}

When you call the `create` method of `WorldManager`, It will automatically create a World resource Instance in the Admin account and assign its World `Capability` to the `WorldManager` for control.

### Module: the way to register components and systems to the world

In some of the sections above, I think you have already noticed. In the implementation of `CounterComponent` and `IncrementSystem`, there are some Factory methods included. We need to register these Factories into the `World` in order to conveniently perform operations through the `WorldManager` at runtime.

`Module` is a type of contract used to uniformly register them into the World.

{% code lineNumbers="true" %}
```swift
import "IComponent"
import "ISystem"
import "IModule"
import "CounterComponent"
import "IncrementSystem"

pub contract SampleModule: IModule {

    pub resource Module: IModule.Installer  {

        /// Returns the name of the module
        ///
        access(all) view
        fun getName(): String {
            return "SampleModule"
        }

        /// Loads the system factories that are provided by the module.
        ///
        access(all)
        fun loadSystemFactories(): @[AnyResource{ISystem.SystemFactory}] {
            let ret: @[AnyResource{ISystem.SystemFactory}] <- []
            ret.append(<- IncrementSystem.createFactory())
            return <- ret
        }

        /// Loads the component factories that are provided by the module.
        ///
        access(all)
        fun loadComponentFactories(): @[AnyResource{IComponent.ComponentFactory}] {
            let ret: @[AnyResource{IComponent.ComponentFactory}] <- []
            ret.append(<- CounterComponent.createFactory())
            return <- ret
        }
    }

    pub fun createModule(): @Module {
        return <- create Module()
    }
}
```
{% endcode %}

Now we can change the previous `createWorld` method: installing the `SampleModule` into the new world through the `installModule` method provided by WorldManager.

{% code lineNumbers="true" %}
```swift
import "CoreWorld"
import "SampleModule"

/// Create a new game world
access(all)
fun createWorld(
    _ admin: Capability<&AuthAccount>,
    name: String
) {
    // Borrow the admin account
    let acct = admin.borrow() ?? panic("Could not borrow admin account")

    // Fetch or create the world manager
    var worldMgr: &CoreWorld.WorldManager? = nil
    if !CoreWorld.hasManager(acct: acct.address) {
        worldMgr = CoreWorld.createManager(admin: admin)
    } else {
        worldMgr = acct.borrow<&CoreWorld.WorldManager>(from: CoreWorld.WorldManagerStoragePath)
    }
    assert(worldMgr != nil, message: "Could not borrow world manager")
    
    // Create the world. The second parameter can also accept a list of System's types.
    // This is used to perform the initialization of System during creation.
    let world = worldMgr!.create(name, withSystems: [])
    
    // Install the module to the world
    worldMgr!.installModule(to: name, <- SampleModule.createModule())
}
```
{% endcode %}

## FAQ

#### Why should I use the Turbine to build a game?

First of all, Turbine is a fully on-chain game framework designed based on the ECS concept([Learn more](../#what-is-ecs-architecture)). This means that it always adheres to the core development concept of separating data from logic. It can provide you with good maintainability and scalability when building games, and a good engineering-oriented, easy-to-collaborate development experience.&#x20;

When you are developing a game, you just need to think step by step:

1.  What kind of data needs to be stored?

    To write `Components` that meet the requirements for various types of entities in the game.
2.  Under what conditions should these data change? What kind of changes will occur?

    To write `Systems` that implement these changes.

Also, you can add new components and systems in the later stage to add additional functionality to entities in the game world.

#### What type of game is it suitable for building by Turbine?

If you want to build a fully on-chain game that exists in some gaming context or game world, then it must be suitable for building with Turbine. In the world context of Turbine, all elements exist in the form of Entities.&#x20;

So you need to convert your game requirements into:

* Which categories should the `Entities` be divided into?
* What `Components` should each category of `Entity` include?
* What `Systems` should manage these `Components` in the `Entities`?

#### What kind of features are not suitable?

If there are a large number of units in the world context (such as some social apps), then such products may not be suitable for using Turbine.

Because we usually need to search for a certain entity in the World through `EntityQuery`, but because the computing gas limit of Flow transaction or script is only `9999`, when the number of units is too large, the available resources for calculation will be very limited.

#### How are Crypto Native features like NFT integrated into Turbine?

Of course, they can. The information associated with these resources can be stored in the `Component`, and when processed in the `System`, access to these Crypto Native assets can be obtained through the information in the `Component`.
