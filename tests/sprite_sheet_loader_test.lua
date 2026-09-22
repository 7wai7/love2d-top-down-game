local AssetManager = require("src.engine.assets.asset_manager")
local assertEqual = require("tests.test_utils").assertEqual

local previousLove = love
local imageLoadCount = 0
local images = {}

love = {
    graphics = {
        newImage = function(path)
            imageLoadCount = imageLoadCount + 1

            local image = {
                path = path,
                width = path == "invalid.png" and 63 or 64,
                height = 24,
                released = false,
            }

            function image:getDimensions()
                return self.width, self.height
            end

            function image:setFilter(minFilter, magFilter)
                self.minFilter = minFilter
                self.magFilter = magFilter
            end

            function image:release()
                self.released = true
            end

            table.insert(images, image)

            return image
        end,
        newQuad = function(x, y, width, height, imageWidth, imageHeight)
            return {
                x = x,
                y = y,
                width = width,
                height = height,
                imageWidth = imageWidth,
                imageHeight = imageHeight,
            }
        end,
    },
}

local manager = AssetManager.new()
manager:register("player.idle", {
    type = "spriteSheet",
    path = "player-idle.png",
    frameWidth = 16,
    frameHeight = 24,
    frameCount = 4,
    filter = "nearest",
})

local sheet = manager:load("player.idle")

assertEqual(imageLoadCount, 1, "image load count")
assertEqual(sheet.image.path, "player-idle.png", "spritesheet image path")
assertEqual(sheet.image.minFilter, "nearest", "minimum image filter")
assertEqual(sheet.image.magFilter, "nearest", "magnification image filter")
assertEqual(sheet.frameWidth, 16, "frame width")
assertEqual(sheet.frameHeight, 24, "frame height")
assertEqual(sheet.frameCount, 4, "frame count")
assertEqual(sheet.columns, 4, "spritesheet columns")
assertEqual(sheet.rows, 1, "spritesheet rows")

for frame = 1, 4 do
    assertEqual(sheet.frames[frame].x, (frame - 1) * 16, "frame x")
    assertEqual(sheet.frames[frame].y, 0, "frame y")
end

assertEqual(manager:load("player.idle"), sheet, "spritesheet cache")
assertEqual(imageLoadCount, 1, "cached image load count")

manager:unload("player.idle")
assert(sheet.image.released, "unloaded spritesheet image should be released")

manager:register("invalid", {
    type = "spriteSheet",
    path = "invalid.png",
    frameWidth = 16,
    frameHeight = 24,
})

local invalidSucceeded = pcall(function()
    manager:load("invalid")
end)

assert(not invalidSucceeded, "invalid spritesheet dimensions should be rejected")
assert(images[#images].released, "failed spritesheet image should be released")
assert(not manager:isLoaded("invalid"), "failed asset should not enter cache")

love = previousLove

print("SpriteSheet loader tests OK")
