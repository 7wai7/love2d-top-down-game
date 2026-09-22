local Animator = {
    type = "Animator",
}

function Animator.new(animationSet, initialAnimation)
    assert(type(animationSet) == "table", "animation set must be a table")
    assert(
        type(initialAnimation) == "string" and animationSet[initialAnimation],
        "initial animation must exist in the animation set"
    )

    return {
        animations = animationSet,
        current = initialAnimation,
        applied = nil,
        frame = 1,
        elapsed = 0,
        speed = 1,
        playing = true,
        finished = false,
    }
end

function Animator.play(animator, animationName, restart)
    assert(
        animator.animations[animationName],
        ("animation '%s' does not exist"):format(tostring(animationName))
    )

    if animator.current == animationName and not restart then
        return false
    end

    animator.current = animationName
    animator.applied = nil

    return true
end

return Animator
