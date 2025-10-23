# Hint System Documentation

## Overview
The Hint System provides an interactive way to display hints and step-by-step instructions for solving algebra problems in AlgeVenture. When activated, it shows an overlay with a character that slides up from the bottom and displays a dialogue box with helpful information.

## Features
- **Overlay**: Semi-transparent black overlay that dims the background
- **Character Animation**: Character sprite slides up from the bottom with a smooth animation
- **Dialogue Box**: Displays hints and step-by-step instructions
- **Close Functionality**: Can be closed via button or ESC key

## File Structure
```
UI/HintSystem/
├── HintSystem.gd        # Main script controlling the hint system
├── HintSystem.tscn      # Scene file with UI layout
└── README.md            # This documentation
```

## Usage

### 1. Adding Hint System to a Scene

In your problem scene script (e.g., `al_1.gd`):

```gdscript
# Preload the hint system scene
var hint_system_scene = preload("res://UI/HintSystem/HintSystem.tscn")
var hint_system_instance = null

func _ready():
    # Initialize hint system
    if hint_system_scene:
        hint_system_instance = hint_system_scene.instantiate()
        add_child(hint_system_instance)
```

### 2. Adding Hint Data to JSON

In your problem JSON files (e.g., `ALevel_1_problem.json`):

```json
{
  "text": "Problem description here...",
  "given": { "a": 5, "d": 3, "n": 10 },
  "formula": "a_n = a + (n - 1)d",
  "answer": 32,
  "hint": "This is an arithmetic sequence problem. Look at the pattern.",
  "steps": [
    "Identify the first term (a = 5)",
    "Find the common difference (d = 3)",
    "Use the formula: a_n = a + (n - 1)d",
    "Substitute values",
    "Calculate the result"
  ]
}
```

### 3. Displaying the Hint

Call the `show_hint()` method with hints and steps arrays:

```gdscript
func _on_hint_button_pressed():
    var problem = _get_current_problem()
    if problem == null:
        return
    
    var hints: Array = []
    var steps: Array = []
    
    if problem.has("hint"):
        hints.append(problem["hint"])
    
    if problem.has("steps"):
        steps = problem["steps"]
    
    if hint_system_instance and hints.size() > 0:
        hint_system_instance.show_hint(hints, steps)
```

## API Reference

### HintSystem.gd

#### Signals
- `hint_closed`: Emitted when the hint system is closed

#### Methods

##### `show_hint(hints: Array, steps: Array)`
Displays the hint system with the provided hints and steps.
- **hints**: Array of hint strings (currently only uses the first one)
- **steps**: Array of step-by-step instruction strings

##### `hide_hint_system()`
Hides the entire hint system immediately without animation.

#### Properties
- `slide_duration`: Duration of the character slide animation (default: 0.5 seconds)

## Animation Timeline

1. **Overlay Fade In** (0.3s): Background dims to semi-transparent black
2. **Character Slide Up** (0.5s): Character slides up from bottom with bounce effect
3. **Dialogue Fade In** (0.3s): Dialogue box fades in

When closing:
1. **Parallel animations** (0.3-0.5s):
   - Dialogue box fades out
   - Character slides down
   - Overlay fades out
2. **Hide all elements**
3. **Emit `hint_closed` signal**

## Customization

### Changing Character Sprite
1. Open `HintSystem.tscn` in Godot
2. Select the "Character" Sprite2D node
3. Assign your character texture in the inspector
4. Adjust scale and position as needed

### Modifying Dialogue Box Appearance
1. Open `HintSystem.tscn` in Godot
2. Select "DialogueBox" PanelContainer
3. Modify the Theme or StyleBox in the inspector
4. Adjust colors, borders, and padding

### Adjusting Animation Speed
In `HintSystem.gd`, modify:
```gdscript
var slide_duration: float = 0.5  # Change this value
```

## Integration Checklist

When adding the hint system to a new problem scene:

- [ ] Add hint button to the scene (UI element)
- [ ] Preload hint system scene in script
- [ ] Instantiate hint system in `_ready()`
- [ ] Connect hint button to handler function
- [ ] Add "hint" and "steps" fields to problem JSON
- [ ] Call `show_hint()` when hint button is pressed
- [ ] Test the hint display and closing functionality

## Example Implementation

See `Scene/LearningPortal.tscn/Artithmethic_levels/al_1.gd` for a complete working example.

## Troubleshooting

### Hint system doesn't appear
- Check that `hint_system_instance` is not null
- Verify that hints array is not empty
- Check console for error messages

### Character doesn't slide up
- Ensure the Character sprite has a texture assigned
- Check that `character_start_y` and `character_target_y` are properly set

### Animation looks wrong
- Adjust `slide_duration` in HintSystem.gd
- Check viewport size - character position is relative to screen height

## Future Enhancements
- Support for multiple hint pages (navigation)
- Character dialogue animation (typing effect)
- Sound effects for opening/closing
- Different character expressions
- Customizable themes per problem type
