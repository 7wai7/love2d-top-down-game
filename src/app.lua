local Engine = require("src.engine.engine")
local AssetManifest = require("src.game.assets.manifest")
local PlayScene = require("src.game.scenes.play_scene")

local App = {}
App.__index = App

function App.new()
    local self = setmetatable({}, App)

    self.engine = Engine.new({
        assetManifest = AssetManifest,
        title = "Top-Down Roguelike",
        fixedDt = 1 / 60,
        maxDelta = 0.25,
        maxFixedSteps = 5,
        clearColor = { 0.08, 0.09, 0.1, 1 },
        debug = true,
    })

    return self
end

function App:load(args)
    self.engine:setScene(PlayScene.new())
    self.engine:load({ args = args or {} })
end

function App:update(dt)
    self.engine:update(dt)
end

function App:draw()
    self.engine:draw()
end

function App:keypressed(key, scancode, isrepeat)
    self.engine:keypressed(key, scancode, isrepeat)
end

function App:keyreleased(key, scancode)
    self.engine:keyreleased(key, scancode)
end

function App:mousepressed(x, y, button, istouch, presses)
    self.engine:mousepressed(x, y, button, istouch, presses)
end

function App:mousereleased(x, y, button, istouch, presses)
    self.engine:mousereleased(x, y, button, istouch, presses)
end

function App:mousemoved(x, y, dx, dy, istouch)
    self.engine:mousemoved(x, y, dx, dy, istouch)
end

function App:wheelmoved(x, y)
    self.engine:wheelmoved(x, y)
end

function App:textinput(text)
    self.engine:textinput(text)
end

function App:resize(width, height)
    self.engine:resize(width, height)
end

function App:focus(isFocused)
    self.engine:focus(isFocused)
end

function App:quit()
    return self.engine:quit()
end

return App
