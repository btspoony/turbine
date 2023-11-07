# What is Turbine?

[Turbine](https://turbine.run) is an ECS-based fully on-chain game engine for **Cadence** smart contract language on the Flow blockchain. It utilizes the **Entity Component System** (ECS) architecture, providing a flexible and powerful on-chain game logic development framework for various games.

### Why Flow and Cadence?

Because they are born for the complex logic on the blockchain:

* Why Flow: [https://developers.flow.com/build/flow](https://developers.flow.com/build/flow)
* Intro to Cadence: [https://developers.flow.com/build/cadence](https://developers.flow.com/build/cadence)

### What is ECS architecture?

ECS, or Entity-Component-System, is a design pattern often used in game development. It's a way of organizing code and data that can provide greater flexibility and performance compared to traditional object-oriented programming (OOP) approaches.&#x20;

In ECS:

1. **Entities** are the objects in your game world. They are typically identified by a unique ID and have no direct behavior or data of their own. Instead, they are composed of various components.
2. **Components** are pure data and contain no behavior. They are used to give entities properties or attributes. For example, a "Position" component might contain x, y, z coordinates, while and  "Health" component might contain a current and maximum health value.
3. **Systems** contain the behavior in an ECS architecture. They operate on entities that have a specific set of components. For example, a "Movement" system might operate on all entities that have both "Position" and "Velocity" components. Systems read the data from components, perform calculations, and write data back to the components.

The ECS architecture allows for high flexibility, as entities can be given any combination of components, and systems can operate on any entities with the required components. This makes it easy to add, remove, or modify features without affecting unrelated systems.

Additionally, because components are pure data, they can be stored in memory in a way that is highly efficient for modern hardware, leading to potential performance benefits. This is particularly important in game development, where performance is often a critical concern.

### What are the unique features of Turbine compared to other FOCG engines?

Flow and Cadence provide features that other blockchains are not able to offer, allowing developers to build complex on-chain game logic more conveniently with Turbine.

* **Protocol level Account Abstraction**: Flow natively supports Account Abstraction and fee-payer delegation on the blockchain, which allows developers to achieve account abstraction and gas fee-payment delegation without relying on complex third-party services. This significantly reduces development time for features related to Massive Adoption. \[[Reference](https://developers.flow.com/build/advanced-concepts/account-abstraction)]
* **Account Linking**: Flow's unique Account Linking feature and extremely low transaction fees allow developers to create a `sandbox` account for each player by creating a new flow account. This grants developers control over the respective `sandbox` account. After guiding players to bind their self-managed wallet (Like [FRW](https://frw.gitbook.io/doc/download/download), [Blocto](https://blocto.io/)) through Link Account, developers and players can share control over the "sandbox spaces". \[[Reference](https://developers.flow.com/build/advanced-concepts/account-linking)]
* **Programmable Read(Scripts) and Write(Transaction) Operations:** Cadence language is a scripting language, it can include any executable Cadence Code within read and write operations. Based on these features, **Turbine** can perform relatively high-speed `Compute Only` mode and persistent operations in `Transaction` mode. With reasonable design, developers can bring a more user-friendly front-end experience to the game.  \[[Refer: Scripts](https://developers.flow.com/build/basics/scripts)] \[[Refer: Transactions](https://developers.flow.com/build/basics/transactions)]
* **Resource Oriented:** As smart contracts often deal with valuable assets, Cadence provides the resource-oriented programming paradigm, which guarantees that assets can only exist in one location at a time, cannot be copied, and cannot be accidentally lost or deleted. These security and safety features allow smart contract developers to focus on the business logic of their contract instead of preventing accidents and attacks. \[[Refer: For Solidity Devs](https://developers.flow.com/cadence/solidity-to-cadence)]\[[Refer: Design Patterns](https://developers.flow.com/cadence/design-patterns)]

