# Hint System Usage Guide

## Quick Start

### For Problem Scenes (Like al_1.gd)

1. **Add these lines at the top of your script:**
```gdscript
var hint_system_scene = preload("res://UI/HintSystem/HintSystem.tscn")
var hint_system_instance = null
@onready var HintButton = $HintButton  # Reference to hint button in scene
```

2. **Initialize in _ready():**
```gdscript
func _ready():
    # ... your existing code ...
    
    # Connect hint button
    if HintButton and not HintButton.pressed.is_connected(_on_hint_button_pressed):
        HintButton.pressed.connect(_on_hint_button_pressed)
    
    # Initialize hint system
    if hint_system_scene:
        hint_system_instance = hint_system_scene.instantiate()
        add_child(hint_system_instance)
```

3. **Add hint button handler:**
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

4. **Show/hide hint button based on problem:**
```gdscript
func _show_current_problem():
    # ... your existing code ...
    
    # Show hint button only if hint data exists
    if HintButton:
        if problem.has("hint") and problem.has("steps"):
            HintButton.show()
        else:
            HintButton.hide()
```

### For Scene Files (.tscn)

Add a hint button node:
```
[node name="HintButton" type="Button" parent="."]
layout_mode = 1
offset_left = 81.0
offset_top = 80.0
offset_right = 172.0
offset_bottom = 111.0
text = "💡 Hint"
```

### For Problem JSON Files

Add hint and steps fields to each problem:
```json
{
  "text": "Your problem text...",
  "given": { "a": 5, "d": 3, "n": 10 },
  "formula": "a_n = a + (n - 1)d",
  "answer": 32,
  "hint": "Brief explanation or tip about the problem",
  "steps": [
    "First step to solve",
    "Second step to solve",
    "Third step to solve",
    "etc."
  ]
}
```

## Visual Flow

```
┌─────────────────────────────────────┐
│  Problem Scene (al_1)               │
│  ┌───────────────┐                  │
│  │ 💡 Hint Button│ ← User clicks    │
│  └───────────────┘                  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  _on_hint_button_pressed()          │
│  • Gets current problem             │
│  • Extracts hint & steps            │
│  • Calls show_hint()                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  HintSystem.show_hint()             │
│  Animation sequence:                │
│  1. Overlay fades in (0.3s)         │
│  2. Character slides up (0.5s)      │
│  3. Dialogue box fades in (0.3s)    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║   OVERLAY (semi-transparent)  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │  💡 Hint                │  ║  │
│  ║  │─────────────────────────│  ║  │
│  ║  │  [Hint text here]       │  ║  │
│  ║  │                         │  ║  │
│  ║  │  Step-by-Step:          │  ║  │
│  ║  │  1. First step          │  ║  │
│  ║  │  2. Second step         │  ║  │
│  ║  │  3. Third step          │  ║  │
│  ║  │                         │  ║  │
│  ║  │  [Close (ESC)]          │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║        ↑                      ║  │
│  ║   [Character sprite]          ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
              ↓
      User closes (button or ESC)
              ↓
┌─────────────────────────────────────┐
│  HintSystem._on_close_button_pressed│
│  Animation sequence:                │
│  1. Dialogue fades out (0.3s)       │
│  2. Character slides down (0.5s)    │
│  3. Overlay fades out (0.3s)        │
│  4. Emits hint_closed signal        │
└─────────────────────────────────────┘
```

## Testing Checklist

- [ ] Hint button appears when problem has hint data
- [ ] Hint button hidden when problem lacks hint data
- [ ] Clicking hint button shows overlay
- [ ] Character slides up smoothly from bottom
- [ ] Dialogue box displays hint text
- [ ] Step-by-step list displays all steps
- [ ] Close button works
- [ ] ESC key closes the hint system
- [ ] Animations are smooth
- [ ] Can continue solving problem after closing hint

## Common Issues & Solutions

### Issue: Hint button doesn't work
**Solution:** Check that:
- Button is connected in _ready()
- hint_system_instance is not null
- Problem JSON has "hint" and "steps" fields

### Issue: Character doesn't appear
**Solution:** 
- Assign a texture to the Character Sprite2D in HintSystem.tscn
- Check Character node is visible in scene tree

### Issue: Animations are too fast/slow
**Solution:** Adjust `slide_duration` in HintSystem.gd

### Issue: Can't close hint system
**Solution:** 
- Check close_button is connected
- Verify ui_cancel action is defined in project settings

## Examples

See these files for working examples:
- `Scene/LearningPortal.tscn/Artithmethic_levels/al_1.gd` - Script integration
- `Scene/LearningPortal.tscn/Artithmethic_levels/al_1.tscn` - Scene setup
- `Scene/LearningPortal.tscn/ARlevel_problems/ALevel_1_problem.json` - JSON structure
