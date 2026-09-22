local Velocity = require("src.game.components.movement.velocity")
local Facing = require("src.game.components.spatial.facing")

local FacingSystem = {}
FacingSystem.__index = FacingSystem

function FacingSystem.new()
    return setmetatable({}, FacingSystem)
end

function FacingSystem:fixedUpdate(world)
    for _, velocity, facing in world:query(Velocity.type, Facing.type) do
        if velocity.x < 0 then
            facing.direction = -1
        elseif velocity.x > 0 then
            facing.direction = 1
        end
    end
end

return FacingSystem
