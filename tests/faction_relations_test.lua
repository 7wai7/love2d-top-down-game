local Faction = require("src.game.components.combat.faction")
local FactionRelations = require("src.game.combat.faction_relations")
local Factions = require("src.game.combat.factions")
local assertEqual = require("tests.test_utils").assertEqual

local playerFaction = Faction.new(Factions.PLAYER)
local dungeonFaction = Faction.new(Factions.DUNGEON)
local neutralFaction = Faction.new(Factions.NEUTRAL)

assertEqual(playerFaction.id, Factions.PLAYER, "player faction component")
assertEqual(dungeonFaction.id, Factions.DUNGEON, "dungeon faction component")

assertEqual(
    FactionRelations.getRelation(playerFaction.id, playerFaction.id),
    FactionRelations.ALLY,
    "same faction relation"
)
assert(FactionRelations.canAssist(playerFaction.id, playerFaction.id),
    "allied factions should allow assistance")
assert(not FactionRelations.canDamage(playerFaction.id, playerFaction.id),
    "allied factions should block damage")

assertEqual(
    FactionRelations.getRelation(playerFaction.id, dungeonFaction.id),
    FactionRelations.HOSTILE,
    "player to dungeon relation"
)
assertEqual(
    FactionRelations.getRelation(dungeonFaction.id, playerFaction.id),
    FactionRelations.HOSTILE,
    "dungeon to player relation"
)
assert(FactionRelations.canTarget(playerFaction.id, dungeonFaction.id),
    "hostile factions should allow automatic targeting")
assert(FactionRelations.canDamage(playerFaction.id, dungeonFaction.id),
    "hostile factions should allow damage")

assertEqual(
    FactionRelations.getRelation(playerFaction.id, neutralFaction.id),
    FactionRelations.NEUTRAL,
    "unspecified faction relation"
)
assert(not FactionRelations.canTarget(playerFaction.id, neutralFaction.id),
    "neutral factions should block automatic targeting")
assert(FactionRelations.canDamage(playerFaction.id, neutralFaction.id),
    "neutral factions should allow direct damage")
assert(not FactionRelations.canAssist(playerFaction.id, neutralFaction.id),
    "neutral factions should block assistance")

local succeeded = pcall(Faction.new, "unknown")
assert(not succeeded, "unknown faction ids should be rejected by the component")

local relationSucceeded = pcall(
    FactionRelations.getRelation,
    Factions.PLAYER,
    "unknown"
)
assert(not relationSucceeded,
    "unknown faction ids should be rejected by the relation resolver")

print("Faction relation tests OK")
