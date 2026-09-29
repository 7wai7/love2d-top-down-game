local Factions = {
    PLAYER = "player",
    DUNGEON = "dungeon",
    NEUTRAL = "neutral",
}

local validIds = {
    [Factions.PLAYER] = true,
    [Factions.DUNGEON] = true,
    [Factions.NEUTRAL] = true,
}

function Factions.isValid(id)
    return validIds[id] == true
end

return Factions
