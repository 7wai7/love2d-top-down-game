local Velocity = {
    type = "Velocity",
}

function Velocity.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

return Velocity
