local Animator = require("src.game.components.animation.animator")
local Sprite = require("src.game.components.rendering.sprite")

local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

-- An animation stores one duration for all frames or a duration for each frame.
local function getFrameDuration(animation, frame)
    if animation.frameDurations then
        return animation.frameDurations[frame]
    end

    return animation.frameDuration
end

-- Copy the current spritesheet frame into the Sprite component used for drawing.
local function applyFrame(sprite, animator, spriteSheet)
    sprite.image = spriteSheet.image
    sprite.quad = spriteSheet.frames[animator.frame]
end

-- Start a newly selected animation from its first frame.
local function resetAnimation(animator)
    animator.applied = animator.current
    animator.frame = 1
    animator.elapsed = 0
    animator.playing = true
    animator.finished = false
end

function AnimationSystem.new()
    return setmetatable({}, AnimationSystem)
end

function AnimationSystem:update(world, dt)
    -- Process only entities that can both animate and render a sprite.
    for _, sprite, animator in world:query(Sprite.type, Animator.type) do
        -- animation is the active clip: { sheet, frameDuration/frameDurations, loop }.
        local animation = animator.animations[animator.current]

        assert(animation, ("animation '%s' does not exist"):format(tostring(animator.current)))

        -- spriteSheet is a loaded asset containing one Image and an ordered frames array.
        local spriteSheet = animation.sheet

        -- Invalid animation data should fail before it reaches love.graphics.draw.
        assert(spriteSheet, ("animation '%s' has no spritesheet"):format(animator.current))
        assert(
            spriteSheet.image,
            ("animation '%s' spritesheet has no image"):format(animator.current)
        )
        assert(
            type(spriteSheet.frames) == "table" and #spriteSheet.frames > 0,
            ("animation '%s' spritesheet has no frames"):format(animator.current)
        )

        -- Changing the animation name resets its timer and frame state.
        if animator.applied ~= animator.current then
            resetAnimation(animator)
        end

        if animator.playing then
            -- elapsed stores unconsumed animation time in seconds.
            -- speed is a playback multiplier: 1 is normal speed, 2 is twice as fast.
            animator.elapsed = animator.elapsed + dt * animator.speed

            -- frameDuration is the number of seconds the current frame should remain visible.
            local frameDuration = getFrameDuration(animation, animator.frame)
            assert(
                type(frameDuration) == "number" and frameDuration > 0,
                ("animation '%s' has an invalid frame duration"):format(animator.current)
            )

            -- A large dt may advance more than one frame, so this must be a loop.
            while animator.elapsed >= frameDuration do
                -- Keep leftover time for the next frame.
                animator.elapsed = animator.elapsed - frameDuration

                if animator.frame < #spriteSheet.frames then
                    -- Move to the next frame inside the current spritesheet.
                    animator.frame = animator.frame + 1
                elseif animation.loop == false then
                    -- A non-looping animation stops on its last frame.
                    animator.playing = false
                    animator.finished = true
                    animator.elapsed = 0
                    break
                else
                    -- Missing loop or loop=true means return to the first frame.
                    animator.frame = 1
                end

                -- The new frame may have its own duration.
                frameDuration = getFrameDuration(animation, animator.frame)
                assert(
                    type(frameDuration) == "number" and frameDuration > 0,
                    ("animation '%s' has an invalid frame duration"):format(animator.current)
                )
            end
        end

        -- Keep Sprite synchronized even while the animation is paused or finished.
        applyFrame(sprite, animator, spriteSheet)
    end
end

return AnimationSystem
