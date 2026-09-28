local Image = {}
Image.__index = Image

function Image.new(image, options)
    assert(image, "UI image element requires a loaded image")

    options = options or {}

    return setmetatable({
        image = image,
        x = options.x or 0,
        y = options.y or 0,
        anchor = options.anchor or "topLeft",
        scaleX = options.scaleX or options.scale or 1,
        scaleY = options.scaleY or options.scale or 1,
        flipX = options.flipX or false,
        flipY = options.flipY or false,
        source = options.source,
        clip = options.clip,
        color = options.color or { 1, 1, 1, 1 },
        visible = options.visible ~= false,
    }, Image)
end

function Image:getSize()
    local width, height = self.image:getDimensions()

    if self.source then
        width = self.source.width
        height = self.source.height
    end

    return width * self.scaleX, height * self.scaleY
end

function Image:draw(renderer, viewport)
    renderer:drawImage(self.image, self, viewport)
end

return Image
