import "Context"
import "IEntity"
import "IComponent"

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
                // init match variables
                var allMatch = self.all.length == 0
                var presentMatch = self.present.length == 0
                var anyMatch = self.any.length == 0
                var disabledMatch = self.disabled.length == 0
                var noneMatch = self.none.length == 0
                var absentMatch = self.absent.length == 0
                // for each component type, check if it matches
                entity.forEachComponents(fun (type: Type, component: &IComponent.Component) {
                    if (allMatch && presentMatch && anyMatch && disabledMatch && noneMatch && absentMatch) {
                        return
                    }

                    let enabled = component.isEnable()
                    // check all
                    if self.all.length > 0 {
                        allMatch = allMatch && (self.all.contains(type) && enabled)
                    }

                    // check present
                    if self.present.length > 0 {
                        presentMatch = presentMatch && self.present.contains(type)
                    }

                    // check any
                    if self.any.length > 0 {
                        anyMatch = anyMatch || (self.any.contains(type) && enabled)
                    }

                    // check none
                    if self.none.length > 0 {
                        noneMatch = noneMatch && (!self.none.contains(type) || !enabled)
                    }

                    // check disabled
                    if self.disabled.length > 0 {
                        disabledMatch = disabledMatch && (self.disabled.contains(type) && !enabled)
                    }

                    // check absent
                    if self.absent.length > 0 {
                        absentMatch = absentMatch && !self.absent.contains(type)
                    }
                })
                // if matched, add to filtered
                if allMatch && presentMatch && anyMatch && disabledMatch && noneMatch && absentMatch {
                    filtered.append(entity)
                }
                i = i + 1
            } // end while
            return filtered
        }
    }
}
