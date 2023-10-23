// Owned imports
import "IComponent"

pub contract GachaPoolComponent: IComponent {

    /// Events

    pub event ItemProbabilityModified(_ uuid: UInt64, itemEntityID: UInt64, probabilityRatio: UFix64)
    pub event BoostingProbabilityItemsModified(_ uuid: UInt64, boostingProbabilityItems: [UInt64])
    pub event CounterModifierUpdated(_ uuid: UInt64, threshold: UInt64, probabilityModifier: [UFix64])

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter, IComponent.ComponentState {
        access(contract) var enabled: Bool

        /// The base probability pool {itemEntityID: probability ratio}
        access(all)
        var baseProbabilityPool: {UInt64: UFix64}
        /// The boosting probability items [itemEntityID]
        access(all)
        var boostingProbabilityItems: [UInt64]
        /// The counter threshold to add extra probability ratio
        access(all)
        var counterThreshold: UInt64
        /// The counter probability pool [add probability ratio]
        access(all)
        var counterProbabilityModifier: [UFix64]

        init() {
            self.enabled = true
            self.baseProbabilityPool = {}
            self.boostingProbabilityItems = []
            self.counterThreshold = UInt64.max
            self.counterProbabilityModifier = []
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        pub fun getKeys(): [String] {
            return [
                "baseProbabilityPool",
                "boostingProbabilityItems",
                "counterThreshold",
                "counterProbabilityModifier"
            ]
        }

        /// Returns the value of the key
        ///
        pub fun getKeyValue(_ key: String): AnyStruct? {
            if key == "baseProbabilityPool" {
                return self.baseProbabilityPool
            } else if key == "boostingProbabilityItems" {
                return self.boostingProbabilityItems
            } else if key == "counterThreshold" {
                return self.counterThreshold
            } else if key == "counterProbabilityModifier" {
                return self.counterProbabilityModifier
            } else {
                return nil
            }
        }

        /// Sets the value of the key
        ///
        pub fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["baseProbabilityPool"] != nil {
                self.baseProbabilityPool = kv["baseProbabilityPool"] as! {UInt64: UFix64}? ?? panic("Invalid baseProbabilityPool")
            }
            if kv["boostingProbabilityItems"] != nil {
                self.boostingProbabilityItems = kv["boostingProbabilityItems"] as! [UInt64]? ?? panic("Invalid boostingProbabilityItems")
            }
            if kv["counterThreshold"] != nil {
                self.counterThreshold = kv["counterThreshold"] as! UInt64? ?? panic("Invalid counterThreshold")
            }
            if kv["counterProbabilityModifier"] != nil {
                self.counterProbabilityModifier = kv["counterProbabilityModifier"] as! [UFix64]? ?? panic("Invalid counterProbabilityModifier")
            }
        }

        /// --- Component Specific methods ---

        /// Returns the probability ratio of the item
        ///
        pub fun getProbabilityRatio(_ itemEntityID: UInt64): UFix64 {
            return self.baseProbabilityPool[itemEntityID]!
        }

        /// Returns the probability ratio of the item with counter
        ///
        pub fun getProbabilityRatioWithCounter(_ itemEntityID: UInt64, _ counter: UInt64): UFix64 {
            if self.boostingProbabilityItems.contains(itemEntityID) && counter >= self.counterThreshold {
                let index = counter - self.counterThreshold
                var modifier: UFix64 = 0.0
                if Int(index) >= self.counterProbabilityModifier.length {
                    modifier = self.counterProbabilityModifier[self.counterProbabilityModifier.length - 1]
                } else {
                    modifier = self.counterProbabilityModifier[index]
                }
                return self.baseProbabilityPool[itemEntityID]! + modifier
            } else {
                return self.baseProbabilityPool[itemEntityID]!
            }
        }

        /// Adds an item to the probability pool
        ///
        pub fun addItem(_ itemEntityID: UInt64, _ probabilityRatio: UFix64): Void {
            self.baseProbabilityPool[itemEntityID] = probabilityRatio

            emit ItemProbabilityModified(self.uuid, itemEntityID: itemEntityID, probabilityRatio: probabilityRatio)
        }

        /// Set the boosting probability items
        ///
        pub fun setBoostingProbabilityItems(_ boostingProbabilityItems: [UInt64]): Void {
            self.boostingProbabilityItems = boostingProbabilityItems

            emit BoostingProbabilityItemsModified(self.uuid, boostingProbabilityItems: boostingProbabilityItems)
        }

        /// Set the counter modifier
        ///
        pub fun setCounterModifier(_ threshold: UInt64, _ mods: [UFix64]): Void {
            self.counterThreshold = threshold
            self.counterProbabilityModifier = mods

            emit CounterModifierUpdated(self.uuid, threshold: threshold, probabilityModifier: mods)
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
