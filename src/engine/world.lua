local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)

    self.nextEntityId = 0
    self.entities = {}
    self.systems = {}
    self.destroyQueue = {}

    return self
end

function World:createEntity(name)
    self.nextEntityId = self.nextEntityId + 1

    local entity = {
        id = self.nextEntityId,
        name = name or ("entity:" .. self.nextEntityId),
        active = true,
    }

    self.entities[entity.id] = entity

    return entity
end

function World:getEntity(id)
    return self.entities[id]
end

function World:destroyEntity(entityOrId)
    local id = type(entityOrId) == "table" and entityOrId.id or entityOrId

    if id then
        self.destroyQueue[id] = true
    end
end

function World:addSystem(system)
    table.insert(self.systems, system)

    if system.init then
        system:init(self)
    end

    return system
end

function World:update(dt, context)
    self:run("update", dt, context)
    self:flushDestroyed()
end

function World:fixedUpdate(dt, context)
    self:run("fixedUpdate", dt, context)
    self:flushDestroyed()
end

function World:draw(context)
    self:run("draw", context)
end

function World:emit(eventName, payload, context)
    for _, system in ipairs(self.systems) do
        if system.onEvent then
            system:onEvent(eventName, payload, context)
        end
    end
end

function World:run(method, ...)
    for _, system in ipairs(self.systems) do
        if system[method] then
            system[method](system, ...)
        end
    end
end

function World:flushDestroyed()
    for id in pairs(self.destroyQueue) do
        local entity = self.entities[id]

        if entity then
            for _, system in ipairs(self.systems) do
                if system.onEntityDestroyed then
                    system:onEntityDestroyed(entity)
                end
            end

            self.entities[id] = nil
        end

        self.destroyQueue[id] = nil
    end
end

function World:clear()
    self.nextEntityId = 0
    self.entities = {}
    self.systems = {}
    self.destroyQueue = {}
end

return World
