local ImageLoader = require("src.engine.assets.loaders.image_loader")
local SpriteSheetLoader = require("src.engine.assets.loaders.sprite_sheet_loader")

local AssetManager = {}
AssetManager.__index = AssetManager

local function copyDescriptor(descriptor)
    local copy = {}

    for key, value in pairs(descriptor) do
        copy[key] = value
    end

    return copy
end

local function assertAssetId(id)
    assert(type(id) == "string" and id ~= "", "asset id must be a non-empty string")
end

function AssetManager.new(options)
    local self = setmetatable({}, AssetManager)

    options = options or {}

    -- descriptors[id] contains a copy of loading metadata registered by the game.
    self.descriptors = {}

    -- cache[id] contains a loaded Image, SpriteSheet, or another loader result.
    self.cache = {}

    -- loading[id] guards against recursively loading the same asset.
    self.loading = {}

    -- loaders[type] implements load(descriptor, manager) and optional unload(resource).
    self.loaders = {
        image = ImageLoader,
        spriteSheet = SpriteSheetLoader,
    }

    for assetType, loader in pairs(options.loaders or {}) do
        self:registerLoader(assetType, loader)
    end

    return self
end

function AssetManager:registerLoader(assetType, loader)
    assert(
        type(assetType) == "string" and assetType ~= "",
        "asset loader type must be a non-empty string"
    )
    assert(
        type(loader) == "table" and type(loader.load) == "function",
        ("asset loader '%s' must provide a load function"):format(assetType)
    )

    self.loaders[assetType] = loader

    return loader
end

-- Registers metadata without loading the asset. IDs must stay unique.
function AssetManager:register(id, descriptor)
    assertAssetId(id)
    assert(type(descriptor) == "table", ("asset '%s' descriptor must be a table"):format(id))
    assert(not self.descriptors[id], ("asset '%s' is already registered"):format(id))
    assert(
        type(descriptor.type) == "string" and self.loaders[descriptor.type],
        ("asset '%s' uses unknown type '%s'"):format(id, tostring(descriptor.type))
    )

    local storedDescriptor = copyDescriptor(descriptor)
    self.descriptors[id] = storedDescriptor

    return storedDescriptor
end

function AssetManager:registerAll(manifest)
    assert(type(manifest) == "table", "asset manifest must be a table")

    for id, descriptor in pairs(manifest) do
        self:register(id, descriptor)
    end

    return self
end

function AssetManager:isRegistered(id)
    return self.descriptors[id] ~= nil
end

function AssetManager:isLoaded(id)
    return self.cache[id] ~= nil
end

-- Loads an asset once and returns the cached result on later calls.
function AssetManager:load(id)
    assertAssetId(id)

    if self.cache[id] ~= nil then
        return self.cache[id]
    end

    local descriptor = self.descriptors[id]
    assert(descriptor, ("asset '%s' is not registered"):format(id))
    assert(not self.loading[id], ("cyclic load detected for asset '%s'"):format(id))

    local loader = self.loaders[descriptor.type]
    self.loading[id] = true

    local succeeded, resource = pcall(loader.load, descriptor, self)
    self.loading[id] = nil

    if not succeeded then
        error(("failed to load asset '%s': %s"):format(id, tostring(resource)), 2)
    end

    assert(resource ~= nil, ("loader for asset '%s' returned nil"):format(id))

    self.cache[id] = resource

    return resource
end

function AssetManager:preload(ids)
    assert(type(ids) == "table", "preload expects an array of asset ids")

    for _, id in ipairs(ids) do
        self:load(id)
    end

    return self
end

-- Returns only an already loaded asset so rendering never starts hidden disk I/O.
function AssetManager:get(id)
    assertAssetId(id)

    local resource = self.cache[id]
    assert(resource ~= nil, ("asset '%s' is not loaded"):format(id))

    return resource
end

-- Unloading invalidates external references; call it only after their users are gone.
function AssetManager:unload(id)
    assertAssetId(id)

    local resource = self.cache[id]
    if resource == nil then
        return false
    end

    local descriptor = self.descriptors[id]
    local loader = self.loaders[descriptor.type]

    if loader.unload then
        loader.unload(resource, descriptor, self)
    end

    self.cache[id] = nil

    return true
end

function AssetManager:clear()
    local loadedIds = {}

    for id in pairs(self.cache) do
        table.insert(loadedIds, id)
    end

    for _, id in ipairs(loadedIds) do
        self:unload(id)
    end
end

return AssetManager
