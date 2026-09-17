local DebugGridSystem = {}
DebugGridSystem.__index = DebugGridSystem

function DebugGridSystem.new(options)
    local self = setmetatable({}, DebugGridSystem)

    options = options or {}
    self.cellSize = options.cellSize or 32

    return self
end

function DebugGridSystem:draw(context)
    if not (love and love.graphics) then
        return
    end

    local width = context.screen.width
    local height = context.screen.height

    love.graphics.setColor(1, 1, 1, 0.06)

    for x = 0, width, self.cellSize do
        love.graphics.line(x, 0, x, height)
    end

    for y = 0, height, self.cellSize do
        love.graphics.line(0, y, width, y)
    end
end

return DebugGridSystem
