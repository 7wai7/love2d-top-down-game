local Image = require("src.engine.ui.elements.image")

local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(options)
    options = options or {}

    local inner = options.inner
    assert(type(inner) == "table", "progress bar requires an inner rectangle")
    assert(
        type(inner.width) == "number" and inner.width > 0 and
            type(inner.height) == "number" and inner.height > 0,
        "progress bar inner rectangle must have a positive size"
    )

    local self = setmetatable({
        frame = Image.new(options.image, {
            x = options.x,
            y = options.y,
            anchor = options.anchor,
            color = options.frameColor,
        }),
        inner = {
            x = inner.x or 0,
            y = inner.y or 0,
            width = inner.width,
            height = inner.height,
        },
        trackColor = options.trackColor or { 0.25, 0.25, 0.25, 1 },
        fillColor = options.fillColor or { 1, 1, 1, 1 },
        direction = options.direction or "leftToRight",
        current = 0,
        max = 1,
        visible = options.visible ~= false,
    }, ProgressBar)

    assert(
        self.direction == "leftToRight" or self.direction == "rightToLeft",
        "progress bar direction must be 'leftToRight' or 'rightToLeft'"
    )

    self:setValue(options.current or 0, options.max or 1)

    return self
end

function ProgressBar:setValue(current, maximum)
    assert(type(current) == "number", "progress bar current value must be a number")
    assert(
        type(maximum) == "number" and maximum > 0,
        "progress bar maximum value must be a positive number"
    )

    self.current = current
    self.max = maximum
end

function ProgressBar:draw(renderer, viewport)
    local frameWidth, frameHeight = self.frame:getSize()
    local frameX, frameY = renderer:resolvePosition(
        self.frame.anchor,
        self.frame.x,
        self.frame.y,
        frameWidth,
        frameHeight,
        viewport
    )
    local innerX = frameX + self.inner.x
    local innerY = frameY + self.inner.y
    local ratio = math.max(0, math.min(self.current / self.max, 1))
    local filledPixels = math.floor(self.inner.width * ratio)

    if ratio > 0 then
        filledPixels = math.max(1, filledPixels)
    end

    local fillX = innerX

    if self.direction == "rightToLeft" then
        fillX = innerX + self.inner.width - filledPixels
    end

    renderer:fillRectangle(
        innerX,
        innerY,
        self.inner.width,
        self.inner.height,
        self.trackColor
    )
    renderer:fillRectangle(
        fillX,
        innerY,
        filledPixels,
        self.inner.height,
        self.fillColor
    )
    self.frame:draw(renderer, viewport)
end

return ProgressBar
