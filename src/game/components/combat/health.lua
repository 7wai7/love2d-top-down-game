local Health = {
    type = "Health",
}

function Health.new(maximum, current)
    assert(type(maximum) == "number" and maximum > 0,
        "maximum health must be a positive number")

    if current == nil then
        current = maximum
    end

    assert(type(current) == "number", "current health must be a number")

    return {
        current = math.max(0, math.min(current, maximum)),
        max = maximum,
    }
end

return Health
