local ProgressBar = require("src.engine.ui.elements.progress_bar")
local UIRenderer = require("src.engine.ui.renderer")
local Health = require("src.game.components.combat.health")
local PlayerControlled = require("src.game.components.player.player_controlled")
local UIManifest = require("src.game.ui.manifest")
local UITheme = require("src.game.ui.theme")

local PlayHud = {}
PlayHud.__index = PlayHud

function PlayHud.new(assets)
    local config = UIManifest.playHud.healthBar
    local healthBar = ProgressBar.new({
        image = assets:load(config.asset),
        anchor = config.anchor,
        x = config.x,
        y = config.y,
        inner = config.inner,
        trackColor = config.trackColor,
        fillColor = config.fillColor,
    })

    return setmetatable({
        renderer = UIRenderer.new({ pixelSize = UITheme.pixelSize }),
        healthBar = healthBar,
        elements = { healthBar },
    }, PlayHud)
end

function PlayHud:update(world)
    self.healthBar.visible = false

    for _, health in world:query(Health.type, PlayerControlled.type) do
        self.healthBar:setValue(health.current, health.max)
        self.healthBar.visible = true
        break
    end
end

function PlayHud:draw(context)
    self.renderer:draw(self.elements, context.screen)
end

return PlayHud
