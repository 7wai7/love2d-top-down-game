local AssetManager = require("src.engine.assets.asset_manager")
local assertEqual = require("tests.test_utils").assertEqual

local loadCount = 0
local unloadCount = 0

local fakeLoader = {
    load = function(descriptor)
        loadCount = loadCount + 1

        return {
            value = descriptor.value,
        }
    end,
    unload = function()
        unloadCount = unloadCount + 1
    end,
}

local manager = AssetManager.new({
    loaders = {
        fake = fakeLoader,
    },
})

local firstDescriptor = {
    type = "fake",
    value = "first",
}

manager:register("first", firstDescriptor)
manager:registerAll({
    second = {
        type = "fake",
        value = "second",
    },
})

firstDescriptor.value = "changed after registration"

assert(manager:isRegistered("first"), "registered asset should be known")
assert(not manager:isLoaded("first"), "registered asset should not load immediately")

local getSucceeded = pcall(function()
    manager:get("first")
end)
assert(not getSucceeded, "get should reject assets that were not loaded")

local firstResource = manager:load("first")
assertEqual(firstResource.value, "first", "registered descriptor copy")
assertEqual(manager:get("first"), firstResource, "get loaded asset")
assertEqual(manager:load("first"), firstResource, "load cached asset")
assertEqual(loadCount, 1, "cached asset load count")

manager:preload({ "second" })
assert(manager:isLoaded("second"), "preloaded asset should be cached")
assertEqual(loadCount, 2, "preload count")

assert(manager:unload("first"), "loaded asset should unload")
assert(not manager:isLoaded("first"), "unloaded asset should leave cache")
assertEqual(unloadCount, 1, "single unload count")
assert(not manager:unload("first"), "unloading absent cache entry should return false")

manager:clear()
assert(not manager:isLoaded("second"), "clear should empty cache")
assertEqual(unloadCount, 2, "clear unload count")

local duplicateSucceeded = pcall(function()
    manager:register("second", {
        type = "fake",
    })
end)
assert(not duplicateSucceeded, "duplicate asset ids should be rejected")

local unknownTypeSucceeded = pcall(function()
    manager:register("unknown", {
        type = "missing-loader",
    })
end)
assert(not unknownTypeSucceeded, "unknown asset types should be rejected")

print("AssetManager tests OK")
