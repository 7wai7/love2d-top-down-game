local Sprite = require("src.game.components.rendering.sprite")
local Position = require("src.game.components.spatial.position")

local unpack = table.unpack or unpack

local SpriteRenderSystem = {}
SpriteRenderSystem.__index = SpriteRenderSystem

local function compareDrawables(left, right)
    if left.sprite.layer ~= right.sprite.layer then
        return left.sprite.layer < right.sprite.layer
    end

    if left.position.y ~= right.position.y then
        return left.position.y < right.position.y
    end

    return left.entity < right.entity
end

function SpriteRenderSystem.new()
    return setmetatable({}, SpriteRenderSystem)
end

function SpriteRenderSystem:draw(world)
    if not (love and love.graphics) then
        return
    end

    local drawables = {}

    for entity, position, sprite in world:query(Position.type, Sprite.type) do
        if sprite.visible and sprite.image then
            table.insert(drawables, {
                entity = entity,
                position = position,
                sprite = sprite,
            })
        end
    end

    table.sort(drawables, compareDrawables)
    love.graphics.push("all")

    for _, drawable in ipairs(drawables) do
        local position = drawable.position
        local sprite = drawable.sprite
        local x = position.x + sprite.offsetX
        local y = position.y + sprite.offsetY

        love.graphics.setColor(unpack(sprite.color))

        if sprite.quad then
            love.graphics.draw(
                sprite.image,
                sprite.quad,
                x,
                y,
                sprite.rotation,
                sprite.scaleX,
                sprite.scaleY,
                sprite.originX,
                sprite.originY
            )
        else
            love.graphics.draw(
                sprite.image,
                x,
                y,
                sprite.rotation,
                sprite.scaleX,
                sprite.scaleY,
                sprite.originX,
                sprite.originY
            )
        end
    end

    love.graphics.pop()
end

return SpriteRenderSystem
