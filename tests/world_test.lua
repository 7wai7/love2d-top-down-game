local World = require("src.engine.world")
local assertEqual = require("tests.test_utils").assertEqual

local world = World.new()
local firstEntity = world:createEntity()
local secondEntity = world:createEntity()

assertEqual(firstEntity, 1, "first entity id")
assertEqual(secondEntity, 2, "second entity id")
assert(world:isAlive(firstEntity), "new entity should be alive")

local firstPosition = world:addComponent(firstEntity, "Position", { x = 10, y = 20 })
world:addComponent(firstEntity, "Velocity", { x = 2, y = 3 })
world:addComponent(secondEntity, "Position", { x = 30, y = 40 })

assertEqual(world:getComponent(firstEntity, "Position"), firstPosition, "stored component")
assert(world:hasComponents(firstEntity, "Position", "Velocity"), "component set should match")
assert(not world:hasComponent(secondEntity, "Velocity"), "missing component should not match")

local matches = 0
for entity, position, velocity in world:query("Position", "Velocity") do
    matches = matches + 1
    assertEqual(entity, firstEntity, "query entity")
    assertEqual(position, firstPosition, "query position")
    assertEqual(velocity.x, 2, "query velocity")
end
assertEqual(matches, 1, "query match count")

local system = {
    fixedUpdate = function(_, currentWorld, dt, context)
        assertEqual(currentWorld, world, "system world")
        assertEqual(dt, 0.5, "system dt")
        assertEqual(context.source, "test", "system context")

        for _, position, velocity in currentWorld:query("Position", "Velocity") do
            position.x = position.x + velocity.x * dt
            position.y = position.y + velocity.y * dt
        end
    end,
}

world:addSystem(system)
world:fixedUpdate(0.5, { source = "test" })
assertEqual(firstPosition.x, 11, "system updated position x")
assertEqual(firstPosition.y, 21.5, "system updated position y")

local removedVelocity = world:removeComponent(firstEntity, "Velocity")
assert(removedVelocity, "removedVelocity component is not returned")
assertEqual(removedVelocity.x, 2, "removed component")
assert(not world:hasComponent(firstEntity, "Velocity"), "removed component should be absent")

assert(world:destroyEntity(firstEntity), "alive entity should be queued for destruction")
assert(not world:isAlive(firstEntity), "queued entity should no longer be alive")
assertEqual(world:getComponent(firstEntity, "Position"), nil, "queued entity should not expose components")

world:update(0, {})
assertEqual(world.entities[firstEntity], nil, "destroyed entity storage")
assertEqual(world.components.Position[firstEntity], nil, "destroyed component storage")
assert(not world:destroyEntity(firstEntity), "destroyed entity cannot be queued again")

print("World ECS tests OK")
