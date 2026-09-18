local Position = require("src.game.components.spatial.position")
local Velocity = require("src.game.components.movement.velocity")

local MovementSystem = {}
MovementSystem.__index = MovementSystem

function MovementSystem.new()
    return setmetatable({}, MovementSystem)
end

function MovementSystem:fixedUpdate(world, dt)
    for _, position, velocity in world:query(Position.type, Velocity.type) do
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
    end
end

return MovementSystem
