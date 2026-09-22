local Engine = require("src.engine.engine")
local assertEqual = require("tests.test_utils").assertEqual

local loadedContext = nil
local scene = {
    load = function(_, context)
        loadedContext = context
    end,
}

local engine = Engine.new({
    assetManifest = {
        ["test.image"] = {
            type = "image",
            path = "assets/test.png",
        },
    },
})

engine:setScene(scene)
engine:load()

assert(loadedContext, "scene should receive an engine context")
assertEqual(loadedContext.assets, engine.assets, "context asset manager")
assert(engine.assets:isRegistered("test.image"), "manifest asset should be registered")
assert(not engine.assets:isLoaded("test.image"), "manifest registration should stay lazy")

print("Engine asset context tests OK")
