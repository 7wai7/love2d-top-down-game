local Facing = {
    type = "Facing",
}

function Facing.new(direction)
    direction = direction or 1

    assert(direction == -1 or direction == 1, "facing direction must be -1 or 1")

    return {
        direction = direction,
    }
end

return Facing
