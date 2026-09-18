local World = require("src.engine.world")
local MovementSpeed = require("src.game.components.movement.movement_speed")
local Velocity = require("src.game.components.movement.velocity")
local PlayerControlled = require("src.game.components.player.player_controlled")
local Position = require("src.game.components.spatial.position")
local DebugGridSystem = require("src.game.systems.debug.debug_grid_system")
local MovementSystem = require("src.game.systems.movement.movement_system")
local PlayerControlSystem = require("src.game.systems.player.player_control_system")

local PlayScene = {}
PlayScene.__index = PlayScene

function PlayScene.new()
    local self = setmetatable({}, PlayScene)

    self.world = World.new()
    self.player = nil

    return self
end

function PlayScene:load(context)
    self.world = World.new()

    self.player = self.world:createEntity()
    self.world:addComponent(
        self.player,
        Position.type,
        Position.new(context.screen.width / 2, context.screen.height / 2)
    )
    self.world:addComponent(self.player, Velocity.type, Velocity.new())
    self.world:addComponent(self.player, MovementSpeed.type, MovementSpeed.new(180))
    self.world:addComponent(self.player, PlayerControlled.type, PlayerControlled.new())

    self.world:addSystem(DebugGridSystem.new({ cellSize = 32 }))
    self.world:addSystem(PlayerControlSystem.new())
    self.world:addSystem(MovementSystem.new())
end

function PlayScene:fixedUpdate(dt, context)
    self.world:fixedUpdate(dt, context)
end

function PlayScene:update(dt, context)
    self.world:update(dt, context)
end

function PlayScene:draw(context)
    self.world:draw(context)
end

return PlayScene
