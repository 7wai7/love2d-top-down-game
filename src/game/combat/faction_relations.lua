local Factions = require("src.game.combat.factions")

local FactionRelations = {
    ALLY = "ally",
    NEUTRAL = "neutral",
    HOSTILE = "hostile",
}

-- Rows describe how the source faction treats each target faction.
local relations = {
    [Factions.PLAYER] = {
        [Factions.DUNGEON] = FactionRelations.HOSTILE,
    },
    [Factions.DUNGEON] = {
        [Factions.PLAYER] = FactionRelations.HOSTILE,
    },
}

local function assertFactionId(id, name)
    assert(
        type(id) == "string" and id ~= "",
        name .. " faction id must be a non-empty string"
    )
    assert(Factions.isValid(id), name .. " faction id is unknown: " .. id)
end

function FactionRelations.getRelation(sourceFactionId, targetFactionId)
    assertFactionId(sourceFactionId, "source")
    assertFactionId(targetFactionId, "target")

    if sourceFactionId == targetFactionId then
        return FactionRelations.ALLY
    end

    local sourceRelations = relations[sourceFactionId]

    if sourceRelations and sourceRelations[targetFactionId] then
        return sourceRelations[targetFactionId]
    end

    return FactionRelations.NEUTRAL
end

function FactionRelations.isHostile(sourceFactionId, targetFactionId)
    return FactionRelations.getRelation(sourceFactionId, targetFactionId) ==
        FactionRelations.HOSTILE
end

function FactionRelations.canTarget(sourceFactionId, targetFactionId)
    return FactionRelations.isHostile(sourceFactionId, targetFactionId)
end

function FactionRelations.canDamage(sourceFactionId, targetFactionId)
    return FactionRelations.getRelation(sourceFactionId, targetFactionId) ~=
        FactionRelations.ALLY
end

function FactionRelations.canAssist(sourceFactionId, targetFactionId)
    return FactionRelations.getRelation(sourceFactionId, targetFactionId) ==
        FactionRelations.ALLY
end

return FactionRelations
