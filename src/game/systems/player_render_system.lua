local PlayerRenderSystem = {}
PlayerRenderSystem.__index = PlayerRenderSystem

function PlayerRenderSystem.new(player)
    local self = setmetatable({}, PlayerRenderSystem)

    self.player = player

    return self
end

function PlayerRenderSystem:draw()
    if not (love and love.graphics) then
        return
    end

    local position = self.player.position
    local radius = self.player.radius

    love.graphics.setColor(0.32, 0.78, 0.65, 1)
    love.graphics.circle("fill", position.x, position.y, radius)

    love.graphics.setColor(0.07, 0.1, 0.11, 1)
    love.graphics.circle("line", position.x, position.y, radius)
end

return PlayerRenderSystem
