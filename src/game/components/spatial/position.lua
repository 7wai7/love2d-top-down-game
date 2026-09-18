local Position = {
    type = "Position",
}

function Position.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

return Position
