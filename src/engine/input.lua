local Input = {}
Input.__index = Input

local function clearTable(items)
    for key in pairs(items) do
        items[key] = nil
    end
end

local function markKey(list, key, scancode)
    if key then
        list[key] = true
    end

    if scancode then
        list[scancode] = true
    end
end

function Input.new()
    local self = setmetatable({}, Input)

    self.keysDown = {}
    self.keysPressed = {}
    self.keysReleased = {}

    self.mouseDown = {}
    self.mousePressed = {}
    self.mouseReleased = {}
    self.mouse = {
        x = 0,
        y = 0,
        dx = 0,
        dy = 0,
        wheelX = 0,
        wheelY = 0,
    }

    self.text = {}
    self.focused = true

    return self
end

function Input:endFrame()
    clearTable(self.keysPressed)
    clearTable(self.keysReleased)
    clearTable(self.mousePressed)
    clearTable(self.mouseReleased)
    clearTable(self.text)

    self.mouse.dx = 0
    self.mouse.dy = 0
    self.mouse.wheelX = 0
    self.mouse.wheelY = 0
end

function Input:isDown(...)
    for _, key in ipairs({ ... }) do
        if self.keysDown[key] then
            return true
        end
    end

    if love and love.keyboard then
        return love.keyboard.isDown(...)
    end

    return false
end

function Input:wasPressed(key)
    return self.keysPressed[key] == true
end

function Input:wasReleased(key)
    return self.keysReleased[key] == true
end

function Input:isMouseDown(button)
    return self.mouseDown[button] == true
end

function Input:wasMousePressed(button)
    return self.mousePressed[button] == true
end

function Input:wasMouseReleased(button)
    return self.mouseReleased[button] == true
end

function Input:getMoveVector()
    local x = 0
    local y = 0

    if self:isDown("left", "a") then
        x = x - 1
    end

    if self:isDown("right", "d") then
        x = x + 1
    end

    if self:isDown("up", "w") then
        y = y - 1
    end

    if self:isDown("down", "s") then
        y = y + 1
    end

    if x ~= 0 and y ~= 0 then
        local diagonal = 1 / math.sqrt(2)
        x = x * diagonal
        y = y * diagonal
    end

    return x, y
end

function Input:keypressed(key, scancode, isrepeat)
    markKey(self.keysDown, key, scancode)

    if not isrepeat then
        markKey(self.keysPressed, key, scancode)
    end
end

function Input:keyreleased(key, scancode)
    if key then
        self.keysDown[key] = nil
    end

    if scancode then
        self.keysDown[scancode] = nil
    end

    markKey(self.keysReleased, key, scancode)
end

function Input:mousepressed(x, y, button)
    self.mouse.x = x
    self.mouse.y = y
    self.mouseDown[button] = true
    self.mousePressed[button] = true
end

function Input:mousereleased(x, y, button)
    self.mouse.x = x
    self.mouse.y = y
    self.mouseDown[button] = nil
    self.mouseReleased[button] = true
end

function Input:mousemoved(x, y, dx, dy)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.dx = self.mouse.dx + dx
    self.mouse.dy = self.mouse.dy + dy
end

function Input:wheelmoved(x, y)
    self.mouse.wheelX = self.mouse.wheelX + x
    self.mouse.wheelY = self.mouse.wheelY + y
end

function Input:textinput(text)
    table.insert(self.text, text)
end

function Input:setFocus(isFocused)
    self.focused = isFocused

    if not isFocused then
        clearTable(self.keysDown)
        clearTable(self.mouseDown)
    end
end

return Input
