local MovementSpeed = {
    type = "MovementSpeed",
}

function MovementSpeed.new(value)
    return {
        value = value or 0,
    }
end

return MovementSpeed
