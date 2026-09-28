local World = require("src.engine.world")
local Health = require("src.game.components.combat.health")
local PlayerControlled = require("src.game.components.player.player_controlled")
local PlayHud = require("src.game.ui.play_hud")
local assertEqual = require("tests.test_utils").assertEqual

local image = {
    getDimensions = function()
        return 40, 7
    end,
}
local assets = {
    load = function(_, id)
        assertEqual(id, "ui.healthBar", "PlayHud asset id")
        return image
    end,
}
local world = World.new()
local enemy = world:createEntity()
local player = world:createEntity()
local playHud = PlayHud.new(assets)

world:addComponent(enemy, Health.type, Health.new(50, 10))
world:addComponent(player, Health.type, Health.new(100, 70))
world:addComponent(player, PlayerControlled.type, PlayerControlled.new())

playHud:update(world)

assert(playHud.healthBar.visible, "health bar should be visible for the local player")
assertEqual(playHud.healthBar.current, 70, "local player health")
assertEqual(playHud.healthBar.max, 100, "local player maximum health")

world:removeComponent(player, PlayerControlled.type)
playHud:update(world)

assert(not playHud.healthBar.visible,
    "health bar should be hidden without a player-controlled entity")

print("PlayHud tests OK")
