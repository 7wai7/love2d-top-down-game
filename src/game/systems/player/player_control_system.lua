local MovementSpeed = require("src.game.components.movement.movement_speed")
local PlayerControlled = require("src.game.components.player.player_controlled")
local Velocity = require("src.game.components.movement.velocity")

local PlayerControlSystem = {}
PlayerControlSystem.__index = PlayerControlSystem

function PlayerControlSystem.new()
    return setmetatable({}, PlayerControlSystem)
end

function PlayerControlSystem:fixedUpdate(world, _, context)
    local x, y = context.input:getMoveVector()

    for _, velocity, movementSpeed in world:query(
        Velocity.type,
        MovementSpeed.type,
        PlayerControlled.type
    ) do
        velocity.x = x * movementSpeed.value
        velocity.y = y * movementSpeed.value
    end
end

return PlayerControlSystem
