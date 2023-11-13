# FAQ

### Why should I use the Turbine to build a game?

First of all, Turbine is a fully on-chain game framework designed based on the ECS concept([Learn more](./#what-is-ecs-architecture)). This means that it always adheres to the core development concept of separating data from logic. It can provide you with good maintainability and scalability when building games, and a good engineering-oriented, easy-to-collaborate development experience.

<figure><img src=".gitbook/assets/Why ECS.png" alt=""><figcaption><p>Why do we need ECS structure?</p></figcaption></figure>

When you are developing a game, you just need to think step by step:

1.  What kind of data needs to be stored?

    To write `Components` that meet the requirements for various types of entities in the game.
2.  Under what conditions should these data change? What kind of changes will occur?

    To write `Systems` that implement these changes.

Also, you can add new components and systems in the later stage to add additional functionality to entities in the game world.

### What type of game is it suitable for building by Turbine?

If you want to build a fully on-chain game that exists in some gaming context or game world, then it must be suitable for building with Turbine. In the world context of Turbine, all elements exist in the form of Entities.

So you need to convert your game requirements into:

* Which categories should the `Entities` be divided into?
* What `Components` should each category of `Entity` include?
* What `Systems` should manage these `Components` in the `Entities`?

### What kind of features are not suitable?

If there are a large number of units in the world context (such as some social apps), then such products may not be suitable for using Turbine.

Because we usually need to search for a certain entity in the World through `EntityQuery`, but because the computing gas limit of Flow transaction or script is only `9999`, when the number of units is too large, the available resources for calculation will be very limited.

### How are Crypto Native features like NFT integrated into Turbine?

Of course, they can. The information associated with these resources can be stored in the `Component`, and when processed in the `System`, access to these Crypto Native assets can be obtained through the information in the `Component`.
