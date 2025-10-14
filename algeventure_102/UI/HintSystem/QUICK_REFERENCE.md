# Hint System Quick Reference Card

## 🚀 Quick Integration (3 Steps)

### Step 1: Add to Script Header
```gdscript
var hint_system_scene = preload("res://UI/HintSystem/HintSystem.tscn")
var hint_system_instance = null
@onready var HintButton = $HintButton
```

### Step 2: Initialize in _ready()
```gdscript
func _ready():
    # Your existing code...
    
    # Add hint system
    if hint_system_scene:
        hint_system_instance = hint_system_scene.instantiate()
        add_child(hint_system_instance)
    
    if HintButton:
        HintButton.pressed.connect(_on_hint_button_pressed)
```

### Step 3: Add Handler Function
```gdscript
func _on_hint_button_pressed():
    var problem = _get_current_problem()
    if problem == null:
        return
    
    var hints = [problem["hint"]] if problem.has("hint") else []
    var steps = problem["steps"] if problem.has("steps") else []
    
    if hint_system_instance and hints.size() > 0:
        hint_system_instance.show_hint(hints, steps)
```

## 📝 JSON Structure

```json
{
  "text": "Problem description...",
  "given": { "a": 5, "d": 3, "n": 10 },
  "formula": "a_n = a + (n - 1)d",
  "answer": 32,
  "hint": "Brief tip or explanation",
  "steps": [
    "Step 1",
    "Step 2",
    "Step 3"
  ]
}
```

## 🎨 Scene Setup

Add button to .tscn file:
```
[node name="HintButton" type="Button" parent="."]
text = "💡 Hint"
```

## 🎯 Show/Hide Logic

```gdscript
func _show_current_problem():
    # Your existing code...
    
    # Show hint button only if hints available
    if HintButton:
        if problem.has("hint") and problem.has("steps"):
            HintButton.show()
        else:
            HintButton.hide()
```

## ⚙️ Customization

### Change Animation Speed
```gdscript
# In HintSystem.gd
var slide_duration: float = 0.5  # Adjust this
```

### Add Character Sprite
1. Open `UI/HintSystem/HintSystem.tscn`
2. Select "Character" node
3. Assign texture in Inspector

### Modify Colors
1. Open `UI/HintSystem/HintSystem.tscn`
2. Select "Overlay" node
3. Change color in Inspector

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Hint doesn't show | Check hints array not empty |
| No animation | Verify Character has texture |
| Button doesn't work | Check connection in _ready() |
| ESC doesn't work | Verify ui_cancel in project settings |

## 📚 Full Documentation

- **README.md** - Complete technical documentation
- **USAGE_GUIDE.md** - Detailed usage examples
- **../HINT_SYSTEM_SUMMARY.md** - Implementation overview

## ✅ Integration Checklist

- [ ] Add imports to script
- [ ] Initialize in _ready()
- [ ] Add handler function
- [ ] Add HintButton to scene
- [ ] Update JSON with hints
- [ ] Test hint display
- [ ] Test closing (button & ESC)
- [ ] Assign character sprite

## 🎬 Expected Behavior

1. Button appears when hints available
2. Click → Overlay fades in (0.3s)
3. Character slides up (0.5s, bounce)
4. Dialogue fades in (0.3s)
5. User reads hint
6. Close → Reverse animation
7. Return to problem

---

**Need help?** See full documentation in README.md
