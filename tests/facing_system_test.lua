local World = require("src.engine.world")
local Velocity = require("src.game.components.movement.velocity")
local Facing = require("src.game.components.spatial.facing")
local FacingSystem = require("src.game.systems.movement.facing_system")
local assertEqual = require("tests.test_utils").assertEqual

local world = World.new()
local entity = world:createEntity()
local velocity = world:addComponent(entity, Velocity.type, Velocity.new())
local facing = world:addComponent(entity, Facing.type, Facing.new())

world:addSystem(FacingSystem.new())

velocity.x = -10
world:fixedUpdate(1 / 60, {})
assertEqual(facing.direction, -1, "negative velocity faces left")

velocity.x = 0
world:fixedUpdate(1 / 60, {})
assertEqual(facing.direction, -1, "zero velocity keeps the previous direction")

velocity.x = 10
world:fixedUpdate(1 / 60, {})
assertEqual(facing.direction, 1, "positive velocity faces right")

print("Facing system tests OK")
