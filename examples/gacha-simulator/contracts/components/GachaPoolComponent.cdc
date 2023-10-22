// Owned imports
import "IComponent"

pub contract GachaPoolComponent: IComponent {

    /// Events

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
                self.baseProbabilityPool = kv["baseProbabilityPool"] as! {UInt64: UFix64}
            }
            if kv["boostingProbabilityItems"] != nil {
                self.boostingProbabilityItems = kv["boostingProbabilityItems"] as! [UInt64]
            }
            if kv["counterThreshold"] != nil {
                self.counterThreshold = kv["counterThreshold"] as! UInt64
            }
            if kv["counterProbabilityModifier"] != nil {
                self.counterProbabilityModifier = kv["counterProbabilityModifier"] as! [UFix64]
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
