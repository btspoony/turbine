import "IEntity"
import "IComponent"
import "Context"

/// The contract of the helper class that allows to query entities.
///
pub contract EntityQuery {

    /// Entity Query Builder
    pub struct Builder {
        pub let all: [Type]
        pub let present: [Type]
        pub let any: [Type]
        pub let none: [Type]
        pub let disabled: [Type]
        pub let absent: [Type]

        init () {
            self.all = []
            self.present = []
            self.any = []
            self.none = []
            self.disabled = []
            self.absent = []
        }

        /// Adds component types to the query.
        /// All component types in this array must exist in the archetype, and must be enabled on matching entities.
        ///
        access(all)
        fun withAll(types: [Type]) {
            for t in types {
                if !self.all.contains(t) {
                    self.all.append(t)
                }
            }
        }

        /// Adds component types to the query.
        /// All of the component types in this array must exist in the archetype, whether or not they are enabled.
        access(all)
        fun withPresent(types: [Type]) {
            for t in types {
                if !self.present.contains(t) {
                    self.present.append(t)
                }
            }
        }

        /// Adds component types to the query.
        /// At least one component type in this array must exist in the archetype, and must be enabled on matching entities.
        ///
        access(all)
        fun withAny(types: [Type]) {
            for t in types {
                if !self.any.contains(t) {
                    self.any.append(t)
                }
            }
        }

        /// Adds component types to the query.
        /// None of the component types in this array can exist in the archetype, or they must be present and disabled on matching entities.
        access(all)
        fun withNone(types: [Type]) {
            for t in types {
                if !self.none.contains(t) {
                    self.none.append(t)
                }
            }
        }

        /// Adds component types to the query.
        /// All component types in this array must exist in the archetype, and must be disabled on matching entities.
        access(all)
        fun withDisabled(types: [Type]) {
            for t in types {
                if !self.disabled.contains(t) {
                    self.disabled.append(t)
                }
            }
        }

        /// Adds component types to the query.
        /// None of the component types in this array can exist in the archetype
        access(all)
        fun withAbsent(types: [Type]) {
            for t in types {
                if !self.absent.contains(t) {
                    self.absent.append(t)
                }
            }
        }

        /// Builds the EntityQuery and executes it, returning the resulting array of entities.
        ///
        access(all)
        fun executeQuery(
            _ ctx: &AnyResource{Context.Provider},
        ): [&IEntity.Entity] {
            let filtered: [&IEntity.Entity] = []
            let all = ctx.borrowAllEntities()
            let len = all.length
            var i = 0
            while i < len {
                let entity = all[i]
                let entityLogStr = "Debug: Entity[".concat(entity.getId().toString()).concat("] - ")
                // quick increment
                i = i + 1
                // init match variables
                var allMatch = self.all.length == 0 ? true : nil
                var presentMatch = self.present.length == 0 ? true : nil
                var anyMatch = self.any.length == 0 ? true : nil
                var disabledMatch = self.disabled.length == 0 ? true : nil
                var noneMatch = self.none.length == 0 ? true : nil
                var absentMatch = self.absent.length == 0 ? true : nil

                // check all
                if self.all.length > 0 {
                    for required in self.all {
                        let comp = entity.borrowComponent(required)
                        allMatch = (allMatch ?? true) && comp != nil && comp!.enabled
                        if comp != nil {
                            log(entityLogStr.concat("WithAll Found - component:".concat(required.identifier))
                                .concat(allMatch == true ? "- T" : "- F"))
                        }
                    }
                }
                // fast continue if allMatch is false
                if allMatch == false {
                    // log(entityLogStr.concat("Checking All - Failure"))
                    continue
                }

                // check present
                if self.present.length > 0 {
                    for required in self.present {
                        let comp = entity.borrowComponent(required)
                        presentMatch = (presentMatch ?? true) && comp != nil
                        if comp != nil {
                            log(entityLogStr.concat("WithPresent Found - component:".concat(required.identifier))
                                .concat(presentMatch == true ? "- T" : "- F"))
                        }
                    }
                }
                // fast continue if presentMatch is false
                if presentMatch == false {
                    // log(entityLogStr.concat("Checking Present - Failure"))
                    continue
                }

                // check any
                if self.any.length > 0 {
                    for required in self.any {
                        let comp = entity.borrowComponent(required)
                        anyMatch = (anyMatch ?? false) || (comp != nil && comp!.enabled)
                        if comp != nil {
                            log(entityLogStr.concat("WithAny Found - component:".concat(required.identifier))
                                .concat(anyMatch == true ? "- T" : "- F"))
                        }
                        if anyMatch == true { // fast break if anyMatch is true
                            break
                        }
                    }
                }
                // fast continue if anyMatch is false
                if anyMatch == false {
                    // log(entityLogStr.concat("Checking Any - Failure"))
                    continue
                }

                // check none
                if self.none.length > 0 {
                    for required in self.none {
                        let comp = entity.borrowComponent(required)
                        noneMatch = (noneMatch ?? true) && (comp == nil || !comp!.enabled)
                    }
                }
                // fast continue if noneMatch is false
                if noneMatch == false {
                    // log(entityLogStr.concat("Checking None - Failure"))
                    continue
                }

                // check disabled
                if self.disabled.length > 0 {
                    for required in self.disabled {
                        let comp = entity.borrowComponent(required)
                        disabledMatch = (disabledMatch ?? true) && (comp != nil && !comp!.enabled)
                    }
                }
                // fast continue if disabledMatch is false
                if disabledMatch == false {
                    // log(entityLogStr.concat("Checking Disabled - Failure"))
                    continue
                }

                // check absent
                if self.absent.length > 0 {
                    for required in self.absent {
                        let comp = entity.borrowComponent(required)
                        absentMatch = (absentMatch ?? true) && comp == nil
                    }
                }
                // fast continue if absentMatch is false
                if absentMatch == false {
                    // log(entityLogStr.concat("Checking Absent - Failure"))
                    continue
                }

                // if matched, add to filtered
                let isMatched = allMatch == true &&
                    presentMatch == true &&
                    anyMatch == true &&
                    disabledMatch == true &&
                    noneMatch == true &&
                    absentMatch == true
                if isMatched {
                    filtered.append(entity)
                }
                log(entityLogStr.concat("Reault: ").concat(isMatched ? "T" : "F"))
            } // end while
            return filtered
        }
    }
}
