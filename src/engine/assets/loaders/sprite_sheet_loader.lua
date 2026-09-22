local ImageLoader = require("src.engine.assets.loaders.image_loader")

local SpriteSheetLoader = {}

local function isPositiveInteger(value)
    return type(value) == "number" and value > 0 and value % 1 == 0
end

local function fail(image, message)
    ImageLoader.unload(image)
    error(message, 3)
end

function SpriteSheetLoader.load(descriptor)
    assert(
        isPositiveInteger(descriptor.frameWidth),
        "spriteSheet asset requires a positive integer frameWidth"
    )
    assert(
        isPositiveInteger(descriptor.frameHeight),
        "spriteSheet asset requires a positive integer frameHeight"
    )

    local image = ImageLoader.load(descriptor)
    local imageWidth, imageHeight = image:getDimensions()

    if imageWidth % descriptor.frameWidth ~= 0
        or imageHeight % descriptor.frameHeight ~= 0
    then
        fail(image, ("spritesheet '%s' size %dx%d is not divisible by frame size %dx%d"):format(
            descriptor.path,
            imageWidth,
            imageHeight,
            descriptor.frameWidth,
            descriptor.frameHeight
        ))
    end

    local columns = imageWidth / descriptor.frameWidth
    local rows = imageHeight / descriptor.frameHeight
    local capacity = columns * rows
    local frameCount = descriptor.frameCount or capacity

    if not isPositiveInteger(frameCount) or frameCount > capacity then
        fail(image, ("spritesheet '%s' frameCount must be between 1 and %d"):format(
            descriptor.path,
            capacity
        ))
    end

    local frames = {}
    for frame = 1, frameCount do
        local index = frame - 1
        local column = index % columns
        local row = math.floor(index / columns)

        frames[frame] = love.graphics.newQuad(
            column * descriptor.frameWidth,
            row * descriptor.frameHeight,
            descriptor.frameWidth,
            descriptor.frameHeight,
            imageWidth,
            imageHeight
        )
    end

    return {
        image = image,
        frames = frames,
        frameWidth = descriptor.frameWidth,
        frameHeight = descriptor.frameHeight,
        frameCount = frameCount,
        columns = columns,
        rows = rows,
    }
end

function SpriteSheetLoader.unload(spriteSheet)
    if spriteSheet then
        ImageLoader.unload(spriteSheet.image)
    end
end

return SpriteSheetLoader
