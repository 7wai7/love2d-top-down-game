local Sprite = {
    type = "Sprite",
}

function Sprite.new(options)
    options = options or {}

    return {
        image = options.image,
        quad = options.quad,
        originX = options.originX or 0,
        originY = options.originY or 0,
        offsetX = options.offsetX or 0,
        offsetY = options.offsetY or 0,
        rotation = options.rotation or 0,
        scaleX = options.scaleX or 1,
        scaleY = options.scaleY or 1,
        color = options.color or { 1, 1, 1, 1 },
        layer = options.layer or 0,
        visible = options.visible ~= false,
    }
end

return Sprite
