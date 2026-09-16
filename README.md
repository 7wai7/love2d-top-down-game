# Top-Down Roguelike

A small 2D top-down roguelike game built with LÖVE and Lua.

The project is mainly created for learning game development, Lua, procedural generation, and basic game engine architecture.

## Game Idea

The player starts inside a procedurally generated dungeon and must find a way out.

The dungeon is made of multiple rooms connected by corridors. The layout changes every time a new game starts, so each run should be different.

The game focuses on exploration, combat, random weapons, enemies, and items.

## Core Gameplay

The basic gameplay includes:

* Procedurally generated dungeons
* Random room placement
* Corridors connecting rooms
* Random player spawn room
* Random exit room
* Player movement
* Player health
* Enemy spawning
* Enemy AI
* Combat
* Weapons
* Projectiles
* Item drops
* Dungeon exit
* Player death and run restart

## Dungeon Generation

A new dungeon is generated for every run.

Rooms may have different sizes and positions. They are placed randomly while avoiding intersections and are connected using corridors.

The generation process should:

* Generate rooms with different sizes
* Place rooms in random positions
* Prevent rooms from overlapping
* Connect rooms with corridors
* Select a starting room
* Select an exit room
* Generate enemies and items inside rooms

Dungeon generation should also support seeds.

Example:

```text
Seed: 573829
```

Using the same seed should generate the same dungeon again. This is useful both for gameplay and debugging.

## Room Types

Different rooms may have different purposes.

Possible room types include:

* Normal combat rooms
* Treasure rooms
* Dangerous rooms with stronger enemies
* Empty rooms
* Secret rooms
* Reward rooms
* Exit rooms

All combat rooms can lock their doors when the player enters. The doors open again after all enemies inside the room are defeated.

## Exit System

The main goal of every run is to find and reach the dungeon exit.

The exit may be available immediately, or additional conditions may need to be completed first.

Possible conditions include:

* Finding a key
* Activating several objects
* Clearing a specific room
* Defeating a special enemy

The exact exit rules may change between different dungeon types or future game modes.

## Combat

The player can find different weapons while exploring the dungeon.

Weapons do not need to follow one specific theme. A medieval character may find a sword, shotgun, magic staff, bomb, or futuristic weapon during the same run.

Possible weapon types include:

* Sword
* Bow
* Pistol
* Shotgun
* Magic staff
* Bomb
* Laser weapon
* Throwing weapons

Weapons can share a common set of properties:

* Damage
* Attack speed
* Range
* Projectile speed
* Projectile count
* Spread
* Knockback

This allows many weapons to reuse the same core logic while having different behavior and values.

## Enemies

Enemies can have completely different themes and visual styles.

Their gameplay behavior is more important than their appearance.

Possible enemy behaviors include:

* **Chaser** — follows the player
* **Shooter** — attacks from a distance
* **Dasher** — quickly moves toward the player
* **Tank** — slow enemy with high health
* **Spawner** — creates other enemies
* **Turret** — stays in one place and shoots

Different enemies may reuse the same behavior.

For example:

```text
Slime       -> Chaser
Skeleton    -> Shooter
Bat         -> Dasher
Knight      -> Tank
Alien Nest  -> Spawner
```

This makes it possible to create many enemies without implementing completely separate AI for every enemy type.

## Items and Player Upgrades

The player may find passive items that modify their character or weapons.

Possible upgrades include:

* Increased movement speed
* Increased damage
* Increased attack speed
* Additional projectiles
* Piercing projectiles
* Bouncing projectiles
* Explosions when enemies die
* Life steal
* Faster reload
* Increased maximum health

Different combinations of upgrades should allow the player to create different builds during each run.

All temporary upgrades are lost when the current run ends.

## Reward Choices

Some rooms may offer several rewards after the player completes them.

For example:

```text
Shotgun

+25% Movement Speed

Heal 30 HP
```

The player can select only one reward.

Rewards may include:

* Weapons
* Passive upgrades
* Healing
* Other special items

## Health and Death

The player has a limited amount of health.

Health does not automatically regenerate. The player must find healing items or receive healing as a reward.

Enemies and other hazards can damage the player.

When the player's health reaches zero, the current run ends.

The player loses temporary weapons and upgrades and starts again in a newly generated dungeon.

## Game Loop

The basic gameplay loop should look like this:

```text
Start a run
    ↓
Explore rooms
    ↓
Fight enemies
    ↓
Find weapons and items
    ↓
Become stronger
    ↓
Search for the exit
    ↓
Escape the dungeon
```

The first version of the game will focus on a single dungeon floor.

In the future, runs may contain several floors:

```text
Floor 1
   ↓
Floor 2
   ↓
Floor 3
   ↓
Boss
   ↓
Escape
```

Difficulty can increase between floors, with stronger enemies and better rewards appearing later in the run.

## Technical Overview

The game is written in Lua and uses the LÖVE framework.

LÖVE provides the low-level functionality required by the game, including:

* Window management
* Rendering
* Keyboard and mouse input
* Audio
* File access

A small custom game engine is built on top of LÖVE.

The engine uses an Entity Component System architecture to keep game data and game logic separated.

The project is expected to contain several general areas:

```text
Game
│
├── Engine
│   ├── ECS
│   ├── Input
│   ├── Rendering
│   ├── Animation
│   ├── Collision
│   └── Asset Management
│
├── Dungeon Generation
│
├── Gameplay
│   ├── Player
│   ├── Enemies
│   ├── Weapons
│   ├── Projectiles
│   └── Items
│
└── UI
```

The exact architecture may change during development as new systems and requirements are added.

## Roadmap

### Engine Foundation

* [ ] Set up the basic LÖVE project structure
* [ ] Implement the main game loop
* [ ] Implement basic ECS architecture
* [ ] Add input handling
* [ ] Add basic rendering
* [ ] Add asset loading and management
* [ ] Add sprite animation support
* [ ] Add collision handling
* [ ] Add basic game state management

### Player

* [ ] Create the player entity
* [ ] Add WASD movement
* [ ] Add player sprite and animations
* [ ] Add player collision
* [ ] Add player health
* [ ] Add taking damage
* [ ] Add player death
* [ ] Add interaction with items and dungeon objects

### Dungeon Generation

* [ ] Generate random rooms
* [ ] Generate rooms with different sizes
* [ ] Prevent room intersections
* [ ] Connect rooms using corridors
* [ ] Generate a starting room
* [ ] Generate an exit room
* [ ] Add seeded dungeon generation
* [ ] Add different room types
* [ ] Add room content generation
* [ ] Add secret rooms

### Room Gameplay

* [ ] Detect when the player enters a room
* [ ] Spawn enemies inside combat rooms
* [ ] Lock combat room doors
* [ ] Detect when all enemies are defeated
* [ ] Unlock completed rooms
* [ ] Add treasure rooms
* [ ] Add reward rooms
* [ ] Add dangerous rooms
* [ ] Add empty rooms

### Combat

* [ ] Implement the basic combat system
* [ ] Add melee attacks
* [ ] Add ranged attacks
* [ ] Add projectiles
* [ ] Add projectile collisions
* [ ] Add damage and knockback
* [ ] Add weapon attack speed
* [ ] Add weapon range
* [ ] Add projectile spread
* [ ] Add multiple projectiles

### Weapons

* [ ] Create a reusable weapon system
* [ ] Add sword
* [ ] Add bow
* [ ] Add pistol
* [ ] Add shotgun
* [ ] Add magic staff
* [ ] Add bombs
* [ ] Add laser weapon
* [ ] Add throwing weapons
* [ ] Add random weapon drops

### Enemies

* [ ] Create the basic enemy entity
* [ ] Add enemy health and damage
* [ ] Implement Chaser behavior
* [ ] Implement Shooter behavior
* [ ] Implement Dasher behavior
* [ ] Implement Tank behavior
* [ ] Implement Spawner behavior
* [ ] Implement Turret behavior
* [ ] Add different enemy sprites and themes
* [ ] Add random enemy spawning

### Items and Upgrades

* [ ] Create a reusable item system
* [ ] Add movement speed upgrades
* [ ] Add damage upgrades
* [ ] Add attack speed upgrades
* [ ] Add additional projectiles
* [ ] Add piercing projectiles
* [ ] Add bouncing projectiles
* [ ] Add enemy death explosions
* [ ] Add life steal
* [ ] Add reload speed upgrades
* [ ] Add maximum health upgrades

### Rewards and Healing

* [ ] Add healing items
* [ ] Add reward selection UI
* [ ] Add weapon rewards
* [ ] Add passive upgrade rewards
* [ ] Add healing rewards
* [ ] Allow choosing one reward from multiple options

### Exit and Run System

* [ ] Add a functional dungeon exit
* [ ] Add immediate exit mode
* [ ] Add key-based exit requirements
* [ ] Add activation-based exit requirements
* [ ] Add special room requirements
* [ ] Restart the run after death
* [ ] Generate a new dungeon after restart
* [ ] Reset temporary weapons and upgrades

### Future Features

* [ ] Add multiple dungeon floors
* [ ] Increase difficulty between floors
* [ ] Add boss enemies
* [ ] Add boss rooms
* [ ] Add better rewards on later floors
* [ ] Add a final escape sequence
* [ ] Add more room types
* [ ] Add more weapons
* [ ] Add more enemies
* [ ] Add more passive upgrades

## Current Status

The project is in an early development stage.

Most gameplay systems and mechanics described in this README are currently planned and will be implemented gradually.
