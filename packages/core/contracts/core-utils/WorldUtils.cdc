import "IEntity"
import "IComponent"
import "CoreWorld"

pub contract WorldUtils {

    /// Dump all entities and components to a dictionary
    ///
    access(all)
    fun dumpEntities(
        _ world: &CoreWorld.World
    ): {UInt64: {String: {String: AnyStruct}}} {
        let ret: {UInt64: {String: {String: AnyStruct}}} = {}

        let entities = world.borrowAllEntities()
        for entity in entities {
            let entityId = entity.uuid
            entity.forEachComponents(fun (type: Type, comp: &IComponent.Component) {
                if !ret.containsKey(entityId) {
                    ret[entityId] = {}
                }
                let compName = type.identifier
                if !ret[entityId]!.containsKey(compName) {
                    ret[entityId]!.insert(key: compName, comp.getData())
                }
            })
        }

        return ret
    }

    /// Import all entities and components from a dictionary
    ///
    access(all)
    fun importEntities(
        _ world: &CoreWorld.World,
        data: {UInt64: {String: {String: AnyStruct}}}
    ) {
        let oldEntities = world.getEntities()

        for entityId in data.keys {
            let entityData = data[entityId]!

            // check if the entity exists
            if let oldIdx = oldEntities.firstIndex(of: entityId) {
                // update for old entity
                let entity = world.borrowEntity(uid: entityId)!
                entity.forEachComponents(fun (type: Type, comp: &IComponent.Component) {
                    let compName = type.identifier
                    if let compData = entityData[compName] {
                        comp.setData(compData)
                    }
                })
                oldEntities.remove(at: oldIdx)
            } else {
                // create for new entity
                let entity = world.createEntity(entityId)
                let entityManeger = world.borrowEntityManager()
                for compName in entityData.keys {
                    let compData = entityData[compName]!
                    let compType = CompositeType(compName)!
                    entityManeger.addComponent(compType, to: entity, withData: compData)
                }
            }
        }

        // remove old entities
        for entityId in oldEntities {
            world.destroyEntity(uid: entityId)
        }
    }
}
