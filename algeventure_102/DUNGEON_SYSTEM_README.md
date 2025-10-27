# Dungeon System Documentation

## Overview

The dungeon system implements a roguelite dungeon crawler with procedural generation, turn-based movement, fog-of-war, and educational combat battles.

## Core Components

### 1. DungeonManager (Autoload)
- **Location**: `res://dungeon_manager.gd`
- **Purpose**: Global singleton managing dungeon state, config selection, and save/load
- **Key Methods**:
  - `load_dungeon(type: String)` - Load arithmetic or geometric dungeon
  - `save_checkpoint()` - Save current progress
  - `load_checkpoint()` - Load saved progress
  - `advance_floor()` - Move to next floor
  - `respawn_at_checkpoint()` - Respawn player after defeat

### 2. DungeonGenerator
- **Location**: `scripts/dungeon/dungeon_generator.gd`
- **Purpose**: Procedural floor generation
- **Features**:
  - 5×10 grid generation
  - Obstacle placement with connectivity checks
  - Enemy, chest, and staircase spawning
  - Staircase placed minimum 5 tiles (Manhattan distance) from spawn

### 3. PlayerController
- **Location**: `scripts/dungeon/player_controller.gd`
- **Purpose**: Handle player movement and fog-of-war
- **Features**:
  - Tile-based movement with animations
  - Move budget tracking (5 moves per floor)
  - Fog-of-war reveal (radius 1, or 2 with torch)
  - Collision detection

### 4. BattleManager
- **Location**: `scripts/dungeon/battle_manager.gd`
- **Purpose**: 3-stage question battle system
- **Stages**:
  1. GIVEN - Identify the given information (MCQ)
  2. FORMULA - Choose the correct formula/approach (MCQ)
  3. ANSWER - Input numeric answer
- **Features**:
  - Wrong answer = damage to player
  - Correct final answer = damage to enemy
  - Scroll usage (remove wrong choices)
  - Calculator toggle
  - Hints system

### 5. Inventory
- **Location**: `scripts/dungeon/inventory.gd`
- **Purpose**: Manage items and equipment
- **Items**:
  - **Potion**: Restore 1 heart
  - **Scroll**: Remove 1-2 wrong choices in battle
  - **Boots**: +2 moves (temporary)
  - **Torch**: Expand fog reveal radius
  - **Armor**: Reduce damage from 1.0 to 0.5

### 6. Data Structures

#### DungeonConfig
- **Location**: `scripts/dungeon/dungeon_config.gd`
- Resource for dungeon configuration
- Export variables for easy inspector editing

#### PlayerState
- **Location**: `scripts/dungeon/player_state.gd`
- Stores player progress, inventory, XP, level
- Serializable for save/load

#### EnemyData
- **Location**: `scripts/dungeon/enemy_data.gd`
- Enemy stats, type, position, rewards

## Usage

### Loading a Dungeon

From main menu:
```gdscript
func _on_dungeon_button_pressed():
    DungeonManager.load_dungeon("arithmetic")  # or "geometric"
```

### Dungeon Scene Flow

1. DungeonManager loads config and initializes PlayerState
2. DungeonScene initializes generator, creates floor
3. Player moves via WASD/arrow keys
4. Fog reveals as player moves
5. Encounters trigger battles
6. Defeat enemies to unlock staircase
7. Reach staircase to advance to next floor

### Configuration

Edit dungeon configs at:
- `data/dungeon/arithmetic_config.tres`
- `data/dungeon/geometric_config.tres`

Exported variables:
- Grid size (rows, cols)
- Enemy count
- Move budget
- Damage values
- Spawn positions
- Staircase distance

## Signals

### DungeonManager
- `dungeon_loaded(dungeon_type: String)`
- `floor_changed(floor_number: int)`
- `checkpoint_saved()`

### PlayerController
- `moved(new_position: Vector2i)`
- `move_depleted()`
- `enemy_encountered(enemy: EnemyData)`
- `chest_opened(position: Vector2i)`
- `staircase_reached()`

### BattleManager
- `battle_started(enemy: EnemyData)`
- `stage_changed(stage: int)`
- `player_damaged(damage: float)`
- `enemy_damaged(damage: int)`
- `battle_ended(victory: bool)`

## Testing

Basic validation tests are available in `/tmp/validate_dungeon.py`:
- Manhattan distance calculations
- Staircase placement logic
- Required kills calculation
- Grid dimensions

## Future Enhancements

1. Visual tile rendering (isometric sprites)
2. Enemy AI and movement
3. Riddler NPC encounters
4. Boss battles
5. Question database integration
6. Animation polish
7. Audio/SFX
8. Persistent XP and progression across runs
9. Achievement system integration
10. Multiple dungeon themes

## File Structure

```
res://
├── dungeon_manager.gd (autoload)
├── data/
│   └── dungeon/
│       ├── arithmetic_config.tres
│       └── geometric_config.tres
├── scenes/
│   └── dungeon/
│       └── dungeon_scene.tscn
└── scripts/
    ├── dungeon/
    │   ├── battle_manager.gd
    │   ├── dungeon_config.gd
    │   ├── dungeon_generator.gd
    │   ├── dungeon_scene.gd
    │   ├── enemy_data.gd
    │   ├── inventory.gd
    │   ├── player_controller.gd
    │   └── player_state.gd
    └── ui/
        ├── battle_overlay.gd
        └── dungeon_hud.gd
```
