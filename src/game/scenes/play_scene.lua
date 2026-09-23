local World = require("src.engine.world")
local Animator = require("src.game.components.animation.animator")
local Enemy = require("src.game.components.enemy.enemy")
local MovementSpeed = require("src.game.components.movement.movement_speed")
local Velocity = require("src.game.components.movement.velocity")
local PlayerControlled = require("src.game.components.player.player_controlled")
local Sprite = require("src.game.components.rendering.sprite")
local Facing = require("src.game.components.spatial.facing")
local Position = require("src.game.components.spatial.position")
local AnimationSystem = require("src.game.systems.animation.animation_system")
local DebugGridSystem = require("src.game.systems.debug.debug_grid_system")
local FacingSystem = require("src.game.systems.movement.facing_system")
local MovementSystem = require("src.game.systems.movement.movement_system")
local PlayerControlSystem = require("src.game.systems.player.player_control_system")
local PlayerMovementAnimationSystem =
    require("src.game.systems.player.player_movement_animation_system")
local SpriteRenderSystem = require("src.game.systems.rendering.sprite_render_system")

local PlayScene = {}
PlayScene.__index = PlayScene

function PlayScene.new()
    local self = setmetatable({}, PlayScene)

    self.world = World.new()
    self.player = nil
    self.enemy = nil

    return self
end

function PlayScene:load(context)
    self.world = World.new()

    self.player = self.world:createEntity()
    self.world:addComponent(
        self.player,
        Position.type,
        Position.new(context.screen.width / 2, context.screen.height / 2)
    )
    self.world:addComponent(self.player, Velocity.type, Velocity.new())
    self.world:addComponent(self.player, MovementSpeed.type, MovementSpeed.new(180))
    self.world:addComponent(self.player, PlayerControlled.type, PlayerControlled.new())
    self.world:addComponent(self.player, Facing.type, Facing.new(1))

    self.enemy = self.world:createEntity()
    self.world:addComponent(self.enemy, Enemy.type, Enemy.new())
    self.world:addComponent(
        self.enemy,
        Position.type,
        Position.new(context.screen.width / 2 + 128, context.screen.height / 2)
    )
    self.world:addComponent(self.enemy, Facing.type, Facing.new(-1))

    -- Rendering components require LÖVE graphics and are skipped by headless tests.
    if love and love.graphics then
        context.assets:preload({
            "player.idle",
            "player.walk",
            "enemy-1.idle",
            "enemy-1.walk",
        })

        local idleSpriteSheet = context.assets:get("player.idle")
        local walkSpriteSheet = context.assets:get("player.walk")
        local animationSet = {
            idle = {
                sheet = idleSpriteSheet,
                frameDuration = 0.2,
            },
            walk = {
                sheet = walkSpriteSheet,
                frameDuration = 0.1,
            },
        }

        self.world:addComponent(self.player, Sprite.type, Sprite.new({
            image = idleSpriteSheet.image,
            quad = idleSpriteSheet.frames[1],
            originX = 8,
            originY = 24,
            scaleX = 3,
            scaleY = 3,
            layer = 10,
        }))
        self.world:addComponent(
            self.player,
            Animator.type,
            Animator.new(animationSet, "idle")
        )

        local enemyIdleSpriteSheet = context.assets:get("enemy-1.idle")
        local enemyWalkSpriteSheet = context.assets:get("enemy-1.walk")
        local enemyAnimationSet = {
            idle = {
                sheet = enemyIdleSpriteSheet,
                frameDuration = 0.2,
            },
            walk = {
                sheet = enemyWalkSpriteSheet,
                frameDuration = 0.1,
            },
        }

        self.world:addComponent(self.enemy, Sprite.type, Sprite.new({
            image = enemyIdleSpriteSheet.image,
            quad = enemyIdleSpriteSheet.frames[1],
            originX = 8,
            originY = 24,
            scaleX = 3,
            scaleY = 3,
            layer = 10,
        }))
        self.world:addComponent(
            self.enemy,
            Animator.type,
            Animator.new(enemyAnimationSet, "idle")
        )
    end

    self.world:addSystem(DebugGridSystem.new({ cellSize = 32 }))
    self.world:addSystem(PlayerControlSystem.new())
    self.world:addSystem(FacingSystem.new())
    self.world:addSystem(MovementSystem.new())
    self.world:addSystem(PlayerMovementAnimationSystem.new())
    self.world:addSystem(AnimationSystem.new())
    self.world:addSystem(SpriteRenderSystem.new())
end

function PlayScene:fixedUpdate(dt, context)
    self.world:fixedUpdate(dt, context)
end

function PlayScene:update(dt, context)
    self.world:update(dt, context)
end

function PlayScene:draw(context)
    self.world:draw(context)
end

return PlayScene
