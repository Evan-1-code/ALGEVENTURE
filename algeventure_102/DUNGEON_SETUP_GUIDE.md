# Adding Dungeon Buttons to Main Menu

This guide explains how to add buttons to the main menu to launch the dungeon mode.

## Method 1: Adding Buttons via Godot Editor (Recommended)

1. Open `Tests/Main_menu.tscn` in the Godot editor
2. Find the UI container where buttons are located (likely a VBoxContainer or HBoxContainer)
3. Add two new Button nodes:
   - Name: `ArithmeticDungeonButton`
   - Text: "Arithmetic Dungeon"
   - Name: `GeometricDungeonButton`
   - Text: "Geometric Dungeon"

4. Connect the button signals to the script:
   - Select ArithmeticDungeonButton
   - In the Node panel, go to Signals
   - Double-click `pressed()`
   - Connect to: `Tests/main_menu.gd`
   - Method name: `_on_dungeon_arithmetic_pressed`
   - Click Connect

   - Repeat for GeometricDungeonButton:
   - Method name: `_on_dungeon_geometric_pressed`

5. The handler methods are already implemented in `Tests/main_menu.gd`:

```gdscript
func _on_dungeon_arithmetic_pressed() -> void:
    if DungeonManager:
        DungeonManager.load_dungeon("arithmetic")

func _on_dungeon_geometric_pressed() -> void:
    if DungeonManager:
        DungeonManager.load_dungeon("geometric")
```

## Method 2: Programmatic Button Creation

If you prefer to create buttons programmatically, add this to `main_menu.gd`:

```gdscript
func _ready() -> void:
    # Existing code...
    
    # Create dungeon buttons
    _create_dungeon_buttons()

func _create_dungeon_buttons() -> void:
    # Find or create a container for the buttons
    var button_container = find_child("ButtonContainer")
    if not button_container:
        button_container = VBoxContainer.new()
        button_container.name = "ButtonContainer"
        add_child(button_container)
    
    # Create Arithmetic button
    var arithmetic_btn = Button.new()
    arithmetic_btn.name = "ArithmeticDungeonButton"
    arithmetic_btn.text = "Arithmetic Dungeon"
    arithmetic_btn.pressed.connect(_on_dungeon_arithmetic_pressed)
    button_container.add_child(arithmetic_btn)
    
    # Create Geometric button
    var geometric_btn = Button.new()
    geometric_btn.name = "GeometricDungeonButton"
    geometric_btn.text = "Geometric Dungeon"
    geometric_btn.pressed.connect(_on_dungeon_geometric_pressed)
    button_container.add_child(geometric_btn)
```

## Testing the Dungeon Mode

1. Run the project (F5)
2. Click one of the dungeon buttons
3. You should see:
   - Console output: "Dungeon initialized: [Arithmetic/Geometric] Depths - Floor 0"
   - A grid of tiles (some colored based on type)
   - HUD showing Hearts, Moves, Floor, and Kills
   - Black fog overlay on unrevealed tiles

4. Use WASD or Arrow Keys to move
5. Press Enter to save checkpoint

## Expected Behavior

- **Movement**: Player can move in 8 directions, limited by move budget (5 moves)
- **Fog-of-War**: Tiles within radius 1 of player are revealed (fog removed)
- **Enemy Encounters**: Moving onto enemy tile triggers battle overlay
- **Chests**: Moving onto chest tile opens it and grants loot
- **Staircase**: Unlocked after defeating 50% of enemies (3 out of 5)

## Troubleshooting

### DungeonManager not found
- Check `project.godot` has: `DungeonManager="*res://dungeon_manager.gd"`
- Restart Godot editor to reload autoloads

### Scene not loading
- Verify `scenes/dungeon/dungeon_scene.tscn` exists
- Check console for error messages

### Tiles not visible
- Grid might be off-screen; adjust camera or tile positions
- Check that `tile.tscn` is properly instantiated

### No movement
- Ensure input actions `move_up`, `move_down`, `move_left`, `move_right` are defined in Project Settings > Input Map
- Check that battle overlay is not showing (blocks movement)

## Next Steps

After adding the buttons and testing basic functionality:

1. **Add player sprite**: Replace the player_controller with a visible sprite
2. **Add tile sprites**: Replace colored rectangles with actual isometric tiles
3. **Question database**: Integrate actual math questions for battles
4. **Polish animations**: Add tween animations for movement
5. **Sound effects**: Add audio for movement, battles, items
6. **Visual effects**: Add particles for items, defeated enemies

## File Locations

- Main Menu: `Tests/Main_menu.tscn`, `Tests/main_menu.gd`
- Dungeon Scene: `scenes/dungeon/dungeon_scene.tscn`
- DungeonManager: `dungeon_manager.gd`
- Config files: `data/dungeon/*.tres`
- Documentation: `DUNGEON_SYSTEM_README.md`
