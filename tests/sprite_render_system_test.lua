local World = require("src.engine.world")
local Sprite = require("src.game.components.rendering.sprite")
local Facing = require("src.game.components.spatial.facing")
local Position = require("src.game.components.spatial.position")
local SpriteRenderSystem = require("src.game.systems.rendering.sprite_render_system")
local assertEqual = require("tests.test_utils").assertEqual

local previousLove = love
local drawCalls = {}

love = {
    graphics = {
        push = function() end,
        pop = function() end,
        setColor = function() end,
        draw = function(image, _, _, _, scaleX)
            table.insert(drawCalls, {
                image = image,
                scaleX = scaleX,
            })
        end,
    },
}

local world = World.new()
local foreground = world:createEntity()
local background = world:createEntity()

world:addComponent(foreground, Position.type, Position.new(20, 40))
world:addComponent(foreground, Facing.type, Facing.new(-1))
world:addComponent(foreground, Sprite.type, Sprite.new({
    image = "foreground",
    layer = 10,
    scaleX = 3,
}))

world:addComponent(background, Position.type, Position.new(20, 100))
world:addComponent(background, Sprite.type, Sprite.new({
    image = "background",
    layer = 0,
    scaleX = 2,
}))

world:addSystem(SpriteRenderSystem.new())
world:draw({})

assertEqual(#drawCalls, 2, "draw call count")
assertEqual(drawCalls[1].image, "background", "lower layer draw order")
assertEqual(drawCalls[2].image, "foreground", "higher layer draw order")
assertEqual(drawCalls[1].scaleX, 2, "sprite without Facing keeps its scale")
assertEqual(drawCalls[2].scaleX, -3, "left-facing sprite uses negative scale")

love = previousLove

print("Sprite render system tests OK")
