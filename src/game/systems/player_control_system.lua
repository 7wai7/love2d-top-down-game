local PlayerControlSystem = {}
PlayerControlSystem.__index = PlayerControlSystem

function PlayerControlSystem.new(player)
    local self = setmetatable({}, PlayerControlSystem)

    self.player = player

    return self
end

function PlayerControlSystem:fixedUpdate(dt, context)
    local input = context.input
    local x, y = input:getMoveVector()

    self.player.velocity.x = x * self.player.speed
    self.player.velocity.y = y * self.player.speed

    local position = self.player.position
    local velocity = self.player.velocity
    local radius = self.player.radius

    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt

    position.x = math.max(radius, math.min(context.screen.width - radius, position.x))
    position.y = math.max(radius, math.min(context.screen.height - radius, position.y))
end

return PlayerControlSystem
