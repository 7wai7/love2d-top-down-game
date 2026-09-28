local previousLove = love

local calls = {}

love = {
    graphics = {
        push = function()
            table.insert(calls, { type = "push" })
        end,
        pop = function()
            table.insert(calls, { type = "pop" })
        end,
        setColor = function() end,
        rectangle = function(mode, x, y, width, height)
            table.insert(calls, {
                type = "rectangle",
                mode = mode,
                x = x,
                y = y,
                width = width,
                height = height,
            })
        end,
        draw = function(image, x, y, rotation, scaleX, scaleY)
            table.insert(calls, {
                type = "image",
                image = image,
                x = x,
                y = y,
                rotation = rotation,
                scaleX = scaleX,
                scaleY = scaleY,
            })
        end,
    },
}

local ProgressBar = require("src.engine.ui.elements.progress_bar")
local UIRenderer = require("src.engine.ui.renderer")
local assertEqual = require("tests.test_utils").assertEqual

local image = {
    getDimensions = function()
        return 40, 7
    end,
}
local progressBar = ProgressBar.new({
    image = image,
    x = 6,
    y = 6,
    inner = {
        x = 5,
        y = 2,
        width = 33,
        height = 3,
    },
    current = 70,
    max = 100,
})
local renderer = UIRenderer.new({ pixelSize = 3 })

renderer:draw({ progressBar }, { width = 960, height = 540 })

assertEqual(calls[1].type, "push", "UI render state start")
assertEqual(calls[2].type, "rectangle", "progress track draw order")
assertEqual(calls[2].x, 33, "progress track x")
assertEqual(calls[2].y, 24, "progress track y")
assertEqual(calls[2].width, 99, "progress track width")
assertEqual(calls[2].height, 9, "progress track height")
assertEqual(calls[3].type, "rectangle", "progress fill draw order")
assertEqual(calls[3].width, 69, "progress fill width")
assertEqual(calls[4].type, "image", "progress frame draw order")
assertEqual(calls[4].image, image, "progress frame image")
assertEqual(calls[4].x, 18, "progress frame x")
assertEqual(calls[4].y, 18, "progress frame y")
assertEqual(calls[4].scaleX, 3, "progress frame horizontal scale")
assertEqual(calls[4].scaleY, 3, "progress frame vertical scale")
assertEqual(calls[5].type, "pop", "UI render state end")

love = previousLove

print("UI renderer tests OK")
