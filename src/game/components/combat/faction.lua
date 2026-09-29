local Factions = require("src.game.combat.factions")

local Faction = {
    type = "Faction",
}

function Faction.new(id)
    assert(Factions.isValid(id), "unknown faction id: " .. tostring(id))

    return {
        id = id,
    }
end

return Faction
