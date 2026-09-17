local World = require("src.engine.world")
local DebugGridSystem = require("src.game.systems.debug_grid_system")
local PlayerControlSystem = require("src.game.systems.player_control_system")
local PlayerRenderSystem = require("src.game.systems.player_render_system")

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

    self.player = self.world:createEntity("player")
    self.player.position = {
        x = context.screen.width / 2,
        y = context.screen.height / 2,
    }
    self.player.velocity = { x = 0, y = 0 }
    self.player.speed = 180
    self.player.radius = 12

    self.world:addSystem(DebugGridSystem.new({ cellSize = 32 }))
    self.world:addSystem(PlayerControlSystem.new(self.player))
    self.world:addSystem(PlayerRenderSystem.new(self.player))
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

function PlayScene:resize(width, height)
    if self.player then
        local radius = self.player.radius

        self.player.position.x = math.max(radius, math.min(width - radius, self.player.position.x))
        self.player.position.y = math.max(radius, math.min(height - radius, self.player.position.y))
    end
end

return PlayScene
