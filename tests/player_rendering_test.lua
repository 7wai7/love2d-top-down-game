local previousLove = love

love = {
    graphics = {
        newImage = function(path)
            return {
                path = path,
                getDimensions = function()
                    return 64, 24
                end,
                setFilter = function() end,
            }
        end,
        newQuad = function(x, y, width, height, sheetWidth, sheetHeight)
            return {
                x = x,
                y = y,
                width = width,
                height = height,
                sheetWidth = sheetWidth,
                sheetHeight = sheetHeight,
            }
        end,
    },
}

local Animator = require("src.game.components.animation.animator")
local AssetManager = require("src.engine.assets.asset_manager")
local Sprite = require("src.game.components.rendering.sprite")
local AssetManifest = require("src.game.assets.manifest")
local PlayScene = require("src.game.scenes.play_scene")
local assertEqual = require("tests.test_utils").assertEqual

local assets = AssetManager.new()
assets:registerAll(AssetManifest)

local context = {
    assets = assets,
    input = {
        getMoveVector = function()
            return 0, 0
        end,
    },
    screen = {
        width = 800,
        height = 600,
    },
}

local scene = PlayScene.new()
scene:load(context)

local sprite = scene.world:getComponent(scene.player, Sprite.type)
local animator = scene.world:getComponent(scene.player, Animator.type)

assert(sprite, "player should have a Sprite when graphics are available")
assert(animator, "player should have an Animator when graphics are available")
assert(animator.animations.idle.sheet.image ~= animator.animations.walk.sheet.image,
    "idle and walk should use separate spritesheet images")
assertEqual(
    animator.animations.idle.sheet.image.path,
    "assets/player-idle.png",
    "idle image path"
)
assertEqual(
    animator.animations.walk.sheet.image.path,
    "assets/player-walk.png",
    "walk image path"
)
assertEqual(#animator.animations.idle.sheet.frames, 4, "idle frame count")
assertEqual(#animator.animations.walk.sheet.frames, 4, "walk frame count")
assertEqual(sprite.image, animator.animations.idle.sheet.image, "initial sprite image")
assertEqual(sprite.quad, animator.animations.idle.sheet.frames[1], "initial sprite frame")

love = previousLove

print("Player rendering tests OK")
