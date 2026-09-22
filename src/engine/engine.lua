local AssetManager = require("src.engine.assets.asset_manager")
local Input = require("src.engine.input")
local Loop = require("src.engine.loop")

local unpack = table.unpack or unpack

local Engine = {}
Engine.__index = Engine

local function call(target, method, ...)
    if target and target[method] then
        return target[method](target, ...)
    end
end

function Engine.new(config)
    local self = setmetatable({}, Engine)

    self.config = config or {}
    self.assets = AssetManager.new()
    self.assets:registerAll(self.config.assetManifest or {})
    self.input = Input.new()
    self.loop = Loop.new({
        fixedDt = self.config.fixedDt,
        maxDelta = self.config.maxDelta,
        maxFixedSteps = self.config.maxFixedSteps,
    })
    self.scene = nil
    self.context = nil
    self.isLoaded = false

    return self
end

function Engine:load(initialContext)
    if love and love.window and self.config.title then
        love.window.setTitle(self.config.title)
    end

    local width, height = 0, 0
    if love and love.graphics then
        width = love.graphics.getWidth()
        height = love.graphics.getHeight()
    end

    self.context = {
        args = initialContext and initialContext.args or {},
        assets = self.assets,
        config = self.config,
        engine = self,
        input = self.input,
        screen = {
            width = width,
            height = height,
        },
    }

    self.isLoaded = true
    self.loop:reset()

    call(self.scene, "load", self.context)
    call(self.scene, "enter", self.context)
end

function Engine:setScene(scene)
    if self.scene == scene then
        return
    end

    if self.isLoaded then
        call(self.scene, "leave", self.context)
    end

    self.scene = scene

    if self.isLoaded then
        call(self.scene, "load", self.context)
        call(self.scene, "enter", self.context)
    end
end

function Engine:update(dt)
    self.loop:update(dt, function(fixedDt)
        call(self.scene, "fixedUpdate", fixedDt, self.context)
    end, function(frameDt, alpha)
        call(self.scene, "update", frameDt, self.context, alpha)
    end)

    self.input:endFrame()
end

function Engine:draw()
    if love and love.graphics then
        love.graphics.push("all")

        if self.config.clearColor then
            love.graphics.clear(unpack(self.config.clearColor))
        end
    end

    call(self.scene, "draw", self.context)

    if self.config.debug then
        self:drawDebugOverlay()
    end

    if love and love.graphics then
        love.graphics.pop()
    end
end

function Engine:drawDebugOverlay()
    if not (love and love.graphics) then
        return
    end

    local stats = self.loop:getStats()

    local fps = 0
    if love.timer and love.timer.getFPS then
        fps = love.timer.getFPS()
    end

    love.graphics.setColor(1, 1, 1, 0.72)
    love.graphics.print(("FPS %d  DT %.4f  Fixed %d"):format(
        fps,
        stats.lastDt,
        stats.fixedSteps
    ), 12, 12)
end

function Engine:keypressed(key, scancode, isrepeat)
    self.input:keypressed(key, scancode, isrepeat)
    call(self.scene, "keypressed", key, scancode, isrepeat, self.context)
end

function Engine:keyreleased(key, scancode)
    self.input:keyreleased(key, scancode)
    call(self.scene, "keyreleased", key, scancode, self.context)
end

function Engine:mousepressed(x, y, button, istouch, presses)
    self.input:mousepressed(x, y, button, istouch, presses)
    call(self.scene, "mousepressed", x, y, button, istouch, presses, self.context)
end

function Engine:mousereleased(x, y, button, istouch, presses)
    self.input:mousereleased(x, y, button, istouch, presses)
    call(self.scene, "mousereleased", x, y, button, istouch, presses, self.context)
end

function Engine:mousemoved(x, y, dx, dy, istouch)
    self.input:mousemoved(x, y, dx, dy, istouch)
    call(self.scene, "mousemoved", x, y, dx, dy, istouch, self.context)
end

function Engine:wheelmoved(x, y)
    self.input:wheelmoved(x, y)
    call(self.scene, "wheelmoved", x, y, self.context)
end

function Engine:textinput(text)
    self.input:textinput(text)
    call(self.scene, "textinput", text, self.context)
end

function Engine:resize(width, height)
    if self.context then
        self.context.screen.width = width
        self.context.screen.height = height
    end

    call(self.scene, "resize", width, height, self.context)
end

function Engine:focus(isFocused)
    self.input:setFocus(isFocused)
    call(self.scene, "focus", isFocused, self.context)
end

function Engine:quit()
    return call(self.scene, "quit", self.context)
end

return Engine
