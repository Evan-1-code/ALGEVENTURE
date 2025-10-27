# Dungeon System - Quick Reference

## System Overview

The dungeon system consists of modular, signal-driven components:

```
DungeonManager (Autoload)
    ├── DungeonConfig (Resource)
    ├── PlayerState (Data)
    └── Save/Load System

DungeonScene (Main Scene)
    ├── DungeonGenerator (Procedural)
    ├── PlayerController (Movement)
    ├── BattleManager (Combat)
    ├── Inventory (Items)
    └── UI (HUD + Battle Overlay)
```

## Key Features Implemented

### 1. Procedural Generation ✓
- 5×10 grid with obstacles (10-18% coverage)
- Flood-fill connectivity check
- 5 enemies, 1-3 chests per floor
- Staircase placed ≥5 tiles from spawn

### 2. Movement & Fog ✓
- 8-directional movement (1 tile per move)
- 5 move budget, restored on enemy defeat
- Fog-of-war with radius 1 (2 with torch)
- Animated tile transitions

### 3. Battle System ✓
- 3 stages: GIVEN → FORMULA → ANSWER
- MCQ for stages 1 & 2, numeric input for stage 3
- Wrong answer = damage (1.0 or 0.5 with armor)
- Scrolls remove wrong choices
- Calculator toggle support

### 4. Inventory ✓
- Potions (heal 1 heart)
- Scrolls (remove wrong choices)
- Armor (reduce damage to 0.5)
- Boots (+2 moves)
- Torch (expand vision)

### 5. Progression ✓
- XP system (100 XP per level)
- Every 2 levels = +1 max heart
- Persistent across runs
- Floor-based checkpoints

### 6. Save/Load ✓
- JSON-based save file
- Stores dungeon type, player state, floor
- Checkpoint after each floor/battle
- Respawn system on defeat

## Code Structure

### Core Scripts (scripts/dungeon/)
- `dungeon_config.gd` - Configuration resource
- `dungeon_generator.gd` - Procedural generation
- `player_state.gd` - Player data
- `enemy_data.gd` - Enemy data
- `player_controller.gd` - Movement logic
- `battle_manager.gd` - Combat system
- `inventory.gd` - Item management
- `dungeon_scene.gd` - Main controller
- `tile.gd` - Individual tile

### UI Scripts (scripts/ui/)
- `dungeon_hud.gd` - HUD display
- `battle_overlay.gd` - Battle UI

### Autoloads
- `dungeon_manager.gd` - Global state manager

### Resources (data/dungeon/)
- `arithmetic_config.tres` - Arithmetic dungeon settings
- `geometric_config.tres` - Geometric dungeon settings

### Scenes (scenes/dungeon/)
- `dungeon_scene.tscn` - Main dungeon scene
- `tile.tscn` - Tile prefab

## Signal Flow

```
User Input
    ↓
PlayerController.move_to()
    ↓ [moved signal]
DungeonScene._on_player_moved()
    ↓
Update fog visuals, check tile
    ↓ [enemy_encountered signal]
BattleManager.start_battle()
    ↓ [battle_started signal]
BattleOverlay.show()
    ↓ [user submits answer]
BattleManager.submit_stage_answer()
    ↓ [correct/incorrect]
    ├─→ Advance stage
    └─→ Apply damage
    ↓ [battle_ended signal]
DungeonScene._on_battle_ended()
    ↓
Restore moves, check staircase unlock
```

## Usage Example

### Loading a Dungeon
```gdscript
# From main menu
DungeonManager.load_dungeon("arithmetic")
# Scene changes to dungeon_scene.tscn
```

### Player Movement
```gdscript
# DungeonScene handles input
func _input(event):
    if event.is_action_pressed("move_right"):
        var target = player_controller.current_position + Vector2i(1, 0)
        player_controller.move_to(target)
```

### Battle Flow
```gdscript
# Auto-triggered on enemy encounter
player_controller.enemy_encountered.connect(_on_enemy_encountered)

func _on_enemy_encountered(enemy: EnemyData):
    battle_manager.start_battle(enemy, player_state)
    battle_overlay.show()
```

### Save/Load
```gdscript
# Save checkpoint
DungeonManager.save_checkpoint()

# Load checkpoint
if DungeonManager.has_save():
    DungeonManager.load_checkpoint()
    DungeonManager.load_dungeon(DungeonManager.current_dungeon_type)
```

## Configuration

All settings are in `DungeonConfig` with @export variables:

```gdscript
@export var rows: int = 5
@export var cols: int = 10
@export var enemy_count: int = 5
@export var starting_moves: int = 5
@export var reveal_radius: int = 1
@export var required_kill_percentage: float = 0.5
```

Edit these in:
- Godot Inspector (when config resource is selected)
- .tres files directly
- Or at runtime via code

## Testing

Run validation tests:
```bash
python3 /tmp/validate_dungeon.py
python3 /tmp/test_dungeon_integration.py
```

## Current Limitations

1. **Visual Polish**: Uses basic colored tiles, needs sprites
2. **Questions**: Placeholder questions, needs real database
3. **AI**: No enemy movement/AI
4. **NPCs**: Riddler not implemented
5. **Audio**: No sound effects or music
6. **Animations**: Basic tween, needs polish

## Next Development Steps

1. Add player/enemy sprites
2. Integrate question database
3. Add tile artwork (isometric)
4. Implement NPC/Riddler
5. Add boss battles
6. Polish animations
7. Add sound effects
8. Create more dungeon types

## Files to Add Manually in Godot

Since some UI work requires the Godot editor:

1. **Main Menu Buttons**:
   - Open `Tests/Main_menu.tscn`
   - Add "Arithmetic Dungeon" button → connect to `_on_dungeon_arithmetic_pressed`
   - Add "Geometric Dungeon" button → connect to `_on_dungeon_geometric_pressed`

2. **Player Sprite**:
   - Create/import player sprite
   - Add to PlayerController as child
   - Position at (0, 0) relative to parent

3. **Tile Sprites**:
   - Import isometric tile sprites
   - Update `tile.tscn` Sprite2D texture
   - Adjust tile_size in configs

4. **Battle Overlay Polish**:
   - Improve layout in `dungeon_scene.tscn`
   - Add backgrounds, borders
   - Better button styling

## Performance Notes

- Grid generation: O(n²) where n = rows × cols
- Connectivity check: O(n²) BFS
- Fog update: O(radius²) per move
- Expected overhead: Minimal for 5×10 grid

## Dependencies

- Godot 4.4+
- No external plugins required
- Uses built-in signals, resources, and scenes

---

For detailed documentation, see:
- `DUNGEON_SYSTEM_README.md` - Complete system documentation
- `DUNGEON_SETUP_GUIDE.md` - Setup instructions

For questions or issues, check console output (debug prints included).
