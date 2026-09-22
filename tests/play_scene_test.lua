local MovementSpeed = require("src.game.components.movement.movement_speed")
local Velocity = require("src.game.components.movement.velocity")
local PlayerControlled = require("src.game.components.player.player_controlled")
local Facing = require("src.game.components.spatial.facing")
local Position = require("src.game.components.spatial.position")
local PlayScene = require("src.game.scenes.play_scene")
local assertEqual = require("tests.test_utils").assertEqual

local context = {
    input = {
        getMoveVector = function()
            return 1, 0
        end,
    },
    screen = {
        width = 800,
        height = 600,
    },
}

local scene = PlayScene.new()
scene:load(context)

local player = scene.player
local world = scene.world

assert(world:isAlive(player), "player entity should be alive")
assert(world:hasComponent(player, PlayerControlled.type), "player should be player-controlled")
assert(world:hasComponents(
    player,
    Position.type,
    Velocity.type,
    MovementSpeed.type,
    Facing.type
), "player should have movement components")

local position = world:getComponent(player, Position.type)
assert(position, "player should have Position")

local velocity = world:getComponent(player, Velocity.type)
assert(velocity, "player should have Velocity")

local facing = world:getComponent(player, Facing.type)
assert(facing, "player should have Facing")

assertEqual(position.x, 400, "initial player x")
assertEqual(position.y, 300, "initial player y")

scene:fixedUpdate(1 / 60, context)

assertEqual(velocity.x, 180, "player velocity x")
assertEqual(velocity.y, 0, "player velocity y")
assertEqual(position.x, 403, "moved player x")
assertEqual(position.y, 300, "moved player y")
assertEqual(facing.direction, 1, "player facing right")

print("PlayScene ECS tests OK")
