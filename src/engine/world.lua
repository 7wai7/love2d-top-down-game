local unpack = table.unpack or unpack

-- World owns all entity IDs, component data, and systems for one ECS simulation.
local World = {}
World.__index = World

-- Returned by a query when one of the requested component stores does not exist.
-- A generic for loop stops immediately when its iterator returns nil.
local function emptyIterator()
    return nil
end

-- Component types are string keys such as "Position" or "PlayerControlled".
local function assertComponentType(componentType)
    assert(
        type(componentType) == "string" and componentType ~= "",
        "component type must be a non-empty string"
    )
end

function World.new()
    local self = setmetatable({}, World)

    -- Last issued numeric entity ID. IDs increase and are not reused during this world's lifetime.
    self.nextEntityId = 0

    -- Set of allocated entities: entities[entityId] = true.
    -- Entity data is not stored here; it lives in the component stores below.
    self.entities = {}

    -- Stores grouped by component type:
    -- components[componentType][entityId] = componentData.
    self.components = {}

    -- Number of entries in each component store:
    -- componentCounts[componentType] = numberOfComponents.
    -- Queries use these counts to start with the smallest possible set of candidates.
    self.componentCounts = {}

    -- Ordered array of systems. Update and draw methods run in insertion order.
    self.systems = {}

    -- Set of entities waiting for safe removal: destroyQueue[entityId] = true.
    -- Queued entities are treated as dead immediately and physically removed after an update.
    self.destroyQueue = {}

    return self
end

-- Allocates and returns a new entity ID. Add components after creating the entity.
function World:createEntity()
    self.nextEntityId = self.nextEntityId + 1
    self.entities[self.nextEntityId] = true

    return self.nextEntityId
end

-- Returns true only while the entity exists and is not queued for destruction.
function World:isAlive(entity)
    return self.entities[entity] == true and not self.destroyQueue[entity]
end

-- Validates an entity before a mutating operation and raises a descriptive error on misuse.
function World:assertEntity(entity)
    assert(
        type(entity) == "number" and self.entities[entity],
        ("entity '%s' does not exist"):format(tostring(entity))
    )
    assert(not self.destroyQueue[entity], ("entity '%s' is pending destruction"):format(entity))
end

-- Marks an entity for deferred destruction.
-- Use this during system updates instead of removing entity data while systems are iterating.
-- Returns false when the entity is missing or was already queued.
function World:destroyEntity(entity)
    if not self:isAlive(entity) then
        return false
    end

    self.destroyQueue[entity] = true

    return true
end

-- Attaches one component table to an existing entity.
-- Call this when spawning an entity or changing its capabilities.
-- An entity can contain only one component of each type.
function World:addComponent(entity, componentType, component)
    self:assertEntity(entity)
    assertComponentType(componentType)
    assert(type(component) == "table", "component data must be a table")

    -- Every component type has its own entity-to-component lookup table.
    local store = self.components[componentType]

    -- A component store is created lazily the first time its type is used.
    if not store then
        store = {}
        self.components[componentType] = store
        self.componentCounts[componentType] = 0
    end

    assert(store[entity] == nil, ("entity '%s' already has component '%s'"):format(
        entity,
        componentType
    ))

    -- Keep the store and its cached size in sync. Do not edit these tables directly.
    store[entity] = component
    self.componentCounts[componentType] = self.componentCounts[componentType] + 1

    return component
end

-- Returns an entity's component table, or nil when either the entity or component is absent.
-- Entities queued for destruction are no longer readable through this public API.
function World:getComponent(entity, componentType)
    assertComponentType(componentType)

    local store = self.components[componentType]

    if not store or not self:isAlive(entity) then
        return nil
    end

    return store[entity]
end

-- Checks whether a living entity contains one specific component type.
function World:hasComponent(entity, componentType)
    return self:getComponent(entity, componentType) ~= nil
end

-- Checks whether a living entity contains every requested component type.
-- This is useful for one-off checks; systems should normally use query().
function World:hasComponents(entity, ...)
    if not self:isAlive(entity) then
        return false
    end

    local componentTypes = { ... }

    for _, componentType in ipairs(componentTypes) do
        if not self:hasComponent(entity, componentType) then
            return false
        end
    end

    return true
end

-- Detaches and returns a component, or returns nil if the entity did not have it.
-- This changes the entity immediately, so later queries will no longer match that component.
function World:removeComponent(entity, componentType)
    self:assertEntity(entity)
    assertComponentType(componentType)

    local store = self.components[componentType]
    local component = store and store[entity]

    if component == nil then
        return nil
    end

    -- Assigning nil removes the key from a Lua table.
    store[entity] = nil
    self.componentCounts[componentType] = self.componentCounts[componentType] - 1

    return component
end

-- Creates an iterator over living entities that have every requested component.
-- The iterator returns the entity ID followed by components in the requested order:
-- for entity, position, velocity in world:query("Position", "Velocity") do ... end
function World:query(...)
    -- Ordered array of component type strings received through Lua's varargs.
    local componentTypes = { ... }
    assert(#componentTypes > 0, "query requires at least one component type")

    -- stores[index] corresponds to componentTypes[index].
    local stores = {}

    -- The smallest store provides the candidate entity IDs. Other stores are only checked
    -- for those candidates, which avoids scanning a large store when a rare tag is requested.
    local smallestStore = nil
    local smallestCount = nil

    for index, componentType in ipairs(componentTypes) do
        assertComponentType(componentType)

        local store = self.components[componentType]

        -- If a requested type has never been added, no entity can match the query.
        if not store then
            return emptyIterator
        end

        stores[index] = store

        local count = self.componentCounts[componentType]
        if smallestCount == nil or count < smallestCount then
            smallestStore = store
            smallestCount = count
        end
    end

    -- Cursor captured by the iterator closure. next(table, key) returns the following entry.
    local entity = nil

    return function()
        while true do
            entity = next(smallestStore, entity)

            -- Returning nil tells Lua's generic for loop that iteration is complete.
            if entity == nil then
                return nil
            end

            -- Queued entities remain in component stores until the update ends, so skip them.
            if self:isAlive(entity) then
                -- Result layout: { entityId, firstComponent, secondComponent, ... }.
                local values = { entity }
                local matches = true

                -- A candidate matches only when every requested store contains its component.
                for index, store in ipairs(stores) do
                    local component = store[entity]

                    if component == nil then
                        matches = false
                        break
                    end

                    values[index + 1] = component
                end

                -- unpack converts the result table into the multiple values expected by for.
                if matches then
                    return unpack(values, 1, #componentTypes + 1)
                end
            end
        end
    end
end

-- Registers a system. Add systems during world setup; their insertion order is significant.
-- init(world), when present, runs immediately after registration.
function World:addSystem(system)
    assert(type(system) == "table", "system must be a table")
    table.insert(self.systems, system)

    if system.init then
        system:init(self)
    end

    return system
end

-- Unregisters a system and calls shutdown(world), when present.
-- Returns false if that exact system instance is not registered.
function World:removeSystem(system)
    for index, currentSystem in ipairs(self.systems) do
        if currentSystem == system then
            if currentSystem.shutdown then
                currentSystem:shutdown(self)
            end

            table.remove(self.systems, index)
            return true
        end
    end

    return false
end

-- Runs variable-step logic once per rendered frame, then applies deferred destruction.
function World:update(dt, context)
    self:run("update", dt, context)
    self:flushDestroyed()
end

-- Runs deterministic fixed-step logic, then applies deferred destruction.
-- Movement and physics systems should normally implement fixedUpdate.
function World:fixedUpdate(dt, context)
    self:run("fixedUpdate", dt, context)
    self:flushDestroyed()
end

-- Runs all system draw methods. Drawing must not mutate ECS gameplay state.
function World:draw(context)
    self:run("draw", context)
end

-- Forwards a window-size change to systems that implement resize.
function World:resize(width, height, context)
    self:run("resize", width, height, context)
end

-- Sends a named game event to every system that implements onEvent.
-- Use this for occasional notifications, not for data that belongs in components.
function World:emit(eventName, payload, context)
    for _, system in ipairs(self.systems) do
        if system.onEvent then
            system:onEvent(self, eventName, payload, context)
        end
    end
end

-- Calls one optional lifecycle method on every system in insertion order.
-- Systems receive themselves through ':' syntax, then world, then the supplied arguments.
function World:run(method, ...)
    for _, system in ipairs(self.systems) do
        if system[method] then
            system[method](system, self, ...)
        end
    end
end

-- Physically removes queued entities and all of their components.
-- This runs only after update phases, when no system query is being traversed.
function World:flushDestroyed()
    for entity in pairs(self.destroyQueue) do
        if self.entities[entity] then
            -- Notify systems before removing storage. The entity is already considered dead.
            for _, system in ipairs(self.systems) do
                if system.onEntityDestroyed then
                    system:onEntityDestroyed(self, entity)
                end
            end

            -- Remove the entity from every component store and maintain cached counts.
            for componentType, store in pairs(self.components) do
                if store[entity] ~= nil then
                    store[entity] = nil
                    self.componentCounts[componentType] = self.componentCounts[componentType] - 1
                end
            end

            self.entities[entity] = nil
        end

        self.destroyQueue[entity] = nil
    end
end

-- Shuts down systems and resets all ECS state.
-- Call this when permanently disposing a world or restarting it in place.
function World:clear()
    for _, system in ipairs(self.systems) do
        if system.shutdown then
            system:shutdown(self)
        end
    end

    self.nextEntityId = 0
    self.entities = {}
    self.components = {}
    self.componentCounts = {}
    self.systems = {}
    self.destroyQueue = {}
end

return World
