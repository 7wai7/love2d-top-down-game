local Animator = require("src.game.components.animation.animator")
local Velocity = require("src.game.components.movement.velocity")
local PlayerControlled = require("src.game.components.player.player_controlled")

local PlayerMovementAnimationSystem = {}
PlayerMovementAnimationSystem.__index = PlayerMovementAnimationSystem

function PlayerMovementAnimationSystem.new()
    return setmetatable({}, PlayerMovementAnimationSystem)
end

function PlayerMovementAnimationSystem:update(world)
    for _, velocity, animator in world:query(
        Velocity.type,
        Animator.type,
        PlayerControlled.type
    ) do
        if animator.current == "idle" or animator.current == "walk" then
            local animationName

            if velocity.x == 0 and velocity.y == 0 then
                animationName = "idle"
            else
                animationName = "walk"
            end

            Animator.play(animator, animationName)
        end
    end
end

return PlayerMovementAnimationSystem
