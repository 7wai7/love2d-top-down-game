local World = require("src.engine.world")
local Animator = require("src.game.components.animation.animator")
local PlayerControlled = require("src.game.components.player.player_controlled")
local Sprite = require("src.game.components.rendering.sprite")
local Velocity = require("src.game.components.movement.velocity")
local AnimationSystem = require("src.game.systems.animation.animation_system")
local PlayerMovementAnimationSystem =
    require("src.game.systems.player.player_movement_animation_system")
local assertEqual = require("tests.test_utils").assertEqual

local idleImage = {}
local walkImage = {}
local idleFrameOne = {}
local idleFrameTwo = {}
local walkFrameOne = {}
local walkFrameTwo = {}

local animationSet = {
    idle = {
        sheet = {
            image = idleImage,
            frames = { idleFrameOne, idleFrameTwo },
        },
        frameDuration = 0.2,
    },
    walk = {
        sheet = {
            image = walkImage,
            frames = { walkFrameOne, walkFrameTwo },
        },
        frameDuration = 0.1,
    },
}

local world = World.new()
local entity = world:createEntity()
local sprite = world:addComponent(entity, Sprite.type, Sprite.new())
local animator = world:addComponent(entity, Animator.type, Animator.new(animationSet, "idle"))
local velocity = world:addComponent(entity, Velocity.type, Velocity.new())
world:addComponent(entity, PlayerControlled.type, PlayerControlled.new())

world:addSystem(PlayerMovementAnimationSystem.new())
world:addSystem(AnimationSystem.new())

world:update(0, {})
assertEqual(sprite.image, idleImage, "idle animation image")
assertEqual(sprite.quad, idleFrameOne, "initial idle frame")

world:update(0.2, {})
assertEqual(sprite.quad, idleFrameTwo, "advanced idle frame")

world:update(0.2, {})
assertEqual(sprite.quad, idleFrameOne, "idle loops by default")

velocity.x = 10
world:update(0, {})
assertEqual(animator.current, "walk", "moving animation name")
assertEqual(sprite.image, walkImage, "walk uses a separate image")
assertEqual(sprite.quad, walkFrameOne, "initial walk frame")

world:update(0.1, {})
assertEqual(sprite.quad, walkFrameTwo, "advanced walk frame")

velocity.x = 0
world:update(0, {})
assertEqual(animator.current, "idle", "stationary animation name")
assertEqual(sprite.image, idleImage, "idle image restored")
assertEqual(sprite.quad, idleFrameOne, "idle animation restarted")

assert(Animator.play(animator, "idle", true), "animation should restart when requested")
world:update(0, {})
assertEqual(animator.frame, 1, "restarted animation frame")

print("Animation tests OK")
