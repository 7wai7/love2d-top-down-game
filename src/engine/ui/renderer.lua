local unpack = table.unpack or unpack

local UIRenderer = {}
UIRenderer.__index = UIRenderer

local validAnchors = {
    bottomLeft = true,
    bottomRight = true,
    center = true,
    topLeft = true,
    topRight = true,
}

local function assertPositiveInteger(value, name)
    assert(
        type(value) == "number" and value > 0 and value % 1 == 0,
        name .. " must be a positive integer"
    )
end

function UIRenderer.new(options)
    options = options or {}

    local pixelSize = options.pixelSize or 1
    assertPositiveInteger(pixelSize, "UI pixel size")

    return setmetatable({
        pixelSize = pixelSize,
        quadCache = setmetatable({}, { __mode = "k" }),
    }, UIRenderer)
end

function UIRenderer:getLogicalViewport(viewport)
    local width = viewport and viewport.width or love.graphics.getWidth()
    local height = viewport and viewport.height or love.graphics.getHeight()

    return math.floor(width / self.pixelSize), math.floor(height / self.pixelSize)
end

function UIRenderer:resolvePosition(anchor, x, y, width, height, viewport)
    anchor = anchor or "topLeft"
    assert(validAnchors[anchor], "unknown UI anchor: " .. tostring(anchor))

    x = x or 0
    y = y or 0

    local viewportWidth, viewportHeight = self:getLogicalViewport(viewport)

    if anchor == "topRight" then
        return viewportWidth - width - x, y
    elseif anchor == "bottomLeft" then
        return x, viewportHeight - height - y
    elseif anchor == "bottomRight" then
        return viewportWidth - width - x, viewportHeight - height - y
    elseif anchor == "center" then
        return math.floor((viewportWidth - width) / 2) + x,
            math.floor((viewportHeight - height) / 2) + y
    end

    return x, y
end

function UIRenderer:getQuad(image, source)
    local imageQuads = self.quadCache[image]

    if not imageQuads then
        imageQuads = {}
        self.quadCache[image] = imageQuads
    end

    local key = table.concat({
        source.x,
        source.y,
        source.width,
        source.height,
    }, ":")

    if not imageQuads[key] then
        local imageWidth, imageHeight = image:getDimensions()
        imageQuads[key] = love.graphics.newQuad(
            source.x,
            source.y,
            source.width,
            source.height,
            imageWidth,
            imageHeight
        )
    end

    return imageQuads[key]
end

function UIRenderer:fillRectangle(x, y, width, height, color)
    if width <= 0 or height <= 0 then
        return
    end

    love.graphics.setColor(unpack(color or { 1, 1, 1, 1 }))
    love.graphics.rectangle(
        "fill",
        x * self.pixelSize,
        y * self.pixelSize,
        width * self.pixelSize,
        height * self.pixelSize
    )
end

function UIRenderer:drawImage(image, options, viewport)
    options = options or {}

    local source = options.source
    local imageWidth, imageHeight = image:getDimensions()
    local sourceWidth = source and source.width or imageWidth
    local sourceHeight = source and source.height or imageHeight
    local scaleX = options.scaleX or options.scale or 1
    local scaleY = options.scaleY or options.scale or 1

    assertPositiveInteger(scaleX, "UI image horizontal scale")
    assertPositiveInteger(scaleY, "UI image vertical scale")

    local width = sourceWidth * scaleX
    local height = sourceHeight * scaleY
    local x, y = self:resolvePosition(
        options.anchor,
        options.x,
        options.y,
        width,
        height,
        viewport
    )
    local drawX = x * self.pixelSize
    local drawY = y * self.pixelSize
    local drawScaleX = scaleX * self.pixelSize
    local drawScaleY = scaleY * self.pixelSize

    if options.flipX then
        drawX = drawX + width * self.pixelSize
        drawScaleX = -drawScaleX
    end

    if options.flipY then
        drawY = drawY + height * self.pixelSize
        drawScaleY = -drawScaleY
    end

    love.graphics.setColor(unpack(options.color or { 1, 1, 1, 1 }))

    local quad = source and self:getQuad(image, source) or nil
    local previousX, previousY, previousWidth, previousHeight
    local clip = options.clip

    if clip then
        previousX, previousY, previousWidth, previousHeight =
            love.graphics.getScissor()
        love.graphics.setScissor(
            clip.x * self.pixelSize,
            clip.y * self.pixelSize,
            clip.width * self.pixelSize,
            clip.height * self.pixelSize
        )
    end

    if quad then
        love.graphics.draw(
            image,
            quad,
            drawX,
            drawY,
            0,
            drawScaleX,
            drawScaleY
        )
    else
        love.graphics.draw(image, drawX, drawY, 0, drawScaleX, drawScaleY)
    end

    if clip then
        if previousX then
            love.graphics.setScissor(
                previousX,
                previousY,
                previousWidth,
                previousHeight
            )
        else
            love.graphics.setScissor()
        end
    end
end

function UIRenderer:draw(elements, viewport)
    if not (love and love.graphics) then
        return
    end

    love.graphics.push("all")

    for _, element in ipairs(elements) do
        if element.visible ~= false then
            element:draw(self, viewport)
        end
    end

    love.graphics.pop()
end

return UIRenderer
