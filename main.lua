if os.getenv("LOVE2D_TOOLS") then pcall(require, "_love2d_tools_bridge") end

local App = require("src.app")

local app

local function dispatch(method, ...)
    if app and app[method] then
        return app[method](app, ...)
    end
end

function love.load(args)
    app = App.new()
    app:load(args)
end

function love.update(dt)
    dispatch("update", dt)
end

function love.draw()
    dispatch("draw")
end

function love.keypressed(key, scancode, isrepeat)
    dispatch("keypressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    dispatch("keyreleased", key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    dispatch("mousepressed", x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    dispatch("mousereleased", x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    dispatch("mousemoved", x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
    dispatch("wheelmoved", x, y)
end

function love.textinput(text)
    dispatch("textinput", text)
end

function love.resize(width, height)
    dispatch("resize", width, height)
end

function love.focus(isFocused)
    dispatch("focus", isFocused)
end

function love.quit()
    return dispatch("quit")
end
