local ImageLoader = {}

local function releaseImage(image)
    if image and image.release then
        image:release()
    end
end

function ImageLoader.load(descriptor)
    assert(
        love and love.graphics and love.graphics.newImage,
        "image assets can only be loaded after LÖVE graphics is initialized"
    )
    assert(
        type(descriptor.path) == "string" and descriptor.path ~= "",
        "image asset requires a non-empty path"
    )

    local image = love.graphics.newImage(descriptor.path)

    if descriptor.filter then
        image:setFilter(
            descriptor.filter,
            descriptor.filter,
            descriptor.anisotropy or 1
        )
    end

    if descriptor.wrapX or descriptor.wrapY then
        image:setWrap(
            descriptor.wrapX or "clamp",
            descriptor.wrapY or descriptor.wrapX or "clamp"
        )
    end

    return image
end

function ImageLoader.unload(image)
    releaseImage(image)
end

return ImageLoader
