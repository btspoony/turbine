# Turbine - A Cadence Fully On-chain Game Engine with ECS Architecture

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit/)

> Turbine is currently in development, and is not yet ready for production use.

Turbine is a fully on-chain game engine for the [Cadence](https://cadence-lang.org/) programming language on [Flow blockchain](https://flow.com/). It utilizes the Entity Component System (ECS) architecture, providing a flexible and powerful framework for developing a wide range of games.

## Contracts

Turbine is composed of a number of contracts that work together to provide a complete game engine.  
The core contracts are:

| Contract | Description |
| --- | --- |
| IComponent | The interface contract for all components. |
| IEntity | The interface contract for all entities. |
| ISystem | The interface contract for all systems. |
| IModule | The interface contract for all modules. |
| IWorld | The interface contract for the game world. |
| Context | The contract including the Consumer and Provider interfaces |
| EntityManager | The contract that manages all entities in the world. |
| CoreEntity | The contract that implements the IEntity interface. |
| CoreWorld | The contract that implements the IWorld interface. |
| EntityQuery | The utiltity contract that queries entities in the world. |
| WorldUtils | The utiltity contract that dump or import all entities for the world.  |

Core contracts can be found on here:

| Network | Address |
| --- | --- |
| Testnet | [0x3102c5131b585d67](https://testnet.flowdiver.io/account/0x3102c5131b585d67) |
