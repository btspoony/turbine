// Owned imports
import "IComponent"

pub contract GachaPoolComponent: IComponent {

    /// Events

    pub event ItemProbabilityModified(_ uuid: UInt64, itemEntityID: UInt64, probabilityRatio: UFix64)
    pub event BoostingProbabilityItemsModified(_ uuid: UInt64, items: [UInt64], boostingRatio: UFix64)
    pub event CounterModifierUpdated(_ uuid: UInt64, threshold: UInt64, probabilityModifier: UFix64)

    /// The component implementation
    ///
    pub resource Component: IComponent.DataProvider, IComponent.DataSetter {
        access(all) var enabled: Bool
        access(contract) let kv: {String: AnyStruct}

        /// The base probability pool {itemEntityID: probability ratio}
        access(self) var baseProbabilityPool: {UInt64: UFix64}

        init() {
            self.enabled = true
            self.baseProbabilityPool = {}

            self.kv = {}
            /// The boosting probability items [itemEntityID]
            let boostingProbabilityItems: [UInt64] = []
            self.kv["boostingProbabilityItems"] = boostingProbabilityItems
            /// The boosting probability ratio
            self.kv["boostingProbabilityRatio"] = 0.0
            /// The counter threshold to add extra probability ratio
            self.kv["counterThreshold"] = UInt64.max
            /// The counter probability pool modifier probability ratio/time
            self.kv["counterProbabilityModifier"] = 0.0
        }

        /// --- General Interface methods ---

        /// Returns the keys of the component
        ///
        access(all) fun getKeys(): [String] {
            return [
                "baseProbabilityPool",
                "boostingProbabilityItems",
                "boostingProbabilityRatio",
                "counterThreshold",
                "counterProbabilityModifier"
            ]
        }

        /// Returns the value of the key
        ///
        access(all) fun getKeyValue(_ key: String): AnyStruct? {
            if key == "baseProbabilityPool" {
                return self.baseProbabilityPool
            } else {
                return self.kv[key]
            }
        }

        /// Sets the value of the key
        ///
        access(all) fun setData(_ kv: {String: AnyStruct?}): Void {
            if kv["baseProbabilityPool"] != nil {
                self.baseProbabilityPool = kv["baseProbabilityPool"] as! {UInt64: UFix64}? ?? panic("Invalid baseProbabilityPool")
            }
            if kv["boostingProbabilityItems"] != nil {
                self.kv["boostingProbabilityItems"] = kv["boostingProbabilityItems"] as! [UInt64]? ?? panic("Invalid boostingProbabilityItems")
            }
            if kv["boostingProbabilityRatio"] != nil {
                self.kv["boostingProbabilityRatio"] = kv["boostingProbabilityRatio"] as! UFix64? ?? panic("Invalid boostingProbabilityRatio")
            }
            if kv["counterThreshold"] != nil {
                self.kv["counterThreshold"] = kv["counterThreshold"] as! UInt64? ?? panic("Invalid counterThreshold")
            }
            if kv["counterProbabilityModifier"] != nil {
                self.kv["counterProbabilityModifier"] = kv["counterProbabilityModifier"] as! UFix64? ?? panic("Invalid counterProbabilityModifier")
            }
        }

        /// --- Component Specific methods ---

        access(all)
        fun getAllItems(): [UInt64] {
            return self.baseProbabilityPool.keys
        }

        access(all)
        fun getBoostingProbabilityItems(): [UInt64] {
            return self.kv["boostingProbabilityItems"] as! [UInt64]
        }

        access(all)
        fun getBoostingProbabilityRatio(): UFix64 {
            return self.kv["boostingProbabilityRatio"] as! UFix64
        }

        access(all)
        fun getCounterThreshold(): UInt64 {
            return self.kv["counterThreshold"] as! UInt64
        }

        access(all)
        fun getCounterProbabilityModifier(): UFix64 {
            return self.kv["counterProbabilityModifier"] as! UFix64
        }

        /// Returns the probability ratio of the item
        ///
        pub fun getProbabilityRatio(_ itemEntityID: UInt64): UFix64 {
            return self.baseProbabilityPool[itemEntityID] ?? panic("Invalid itemEntityID")
        }

        /// Returns the probability ratio of the item with counter
        ///
        pub fun getProbabilityRatioModWithRareCounter(_ counter: UInt64): UFix64 {
            let threshold: UInt64 = self.getCounterThreshold()
            if counter > threshold {
                let index: UInt64 = counter - threshold
                let modifierBase = self.getCounterProbabilityModifier()
                var modifier: UFix64 = modifierBase * UFix64.fromString(index.toString().concat(".0"))!
                return modifier > 1.0 ? 1.0 : modifier
            } else {
                return 0.0
            }
        }

        /// Adds an item to the probability pool
        ///
        pub fun addItem(_ itemEntityID: UInt64, _ probabilityRatio: UFix64): Void {
            self.baseProbabilityPool[itemEntityID] = probabilityRatio

            emit ItemProbabilityModified(self.uuid, itemEntityID: itemEntityID, probabilityRatio: probabilityRatio)
        }

        /// Adds items to the probability pool
        ///
        pub fun addItems(items: {UInt64: UFix64}): Void {
            for itemEntityID in items.keys {
                self.baseProbabilityPool[itemEntityID] = items[itemEntityID]
                emit ItemProbabilityModified(self.uuid, itemEntityID: itemEntityID, probabilityRatio: items[itemEntityID]!)
            }
        }

        /// Set the boosting probability items
        ///
        pub fun setBoostingProbabilityItems(_ boostingProbabilityItems: [UInt64], _ boostingProbabilityRatio: UFix64): Void {
            self.kv["boostingProbabilityItems"] = boostingProbabilityItems
            self.kv["boostingProbabilityRatio"] = boostingProbabilityRatio

            emit BoostingProbabilityItemsModified(self.uuid, items: boostingProbabilityItems, boostingRatio: boostingProbabilityRatio)
        }

        /// Set the counter modifier
        ///
        pub fun setCounterModifier(_ threshold: UInt64, _ mod: UFix64): Void {
            self.kv["counterThreshold"] = threshold
            self.kv["counterProbabilityModifier"] = mod

            emit CounterModifierUpdated(self.uuid, threshold: threshold, probabilityModifier: mod)
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
