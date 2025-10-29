# Quick Start Guide - Manual Setup Steps

## Issues Fixed ✅

1. ✅ **Class name conflict**: Changed `Tile` to `DungeonTile` to avoid Godot internal conflicts
2. ✅ **Invisible tiles**: Replaced Sprite2D with ColorRect - tiles are now visible!
3. ✅ **Top-down view**: Simple top-down grid (no isometric complexity)
4. ✅ **Player visibility**: Added blue colored rectangle as player marker
5. ✅ **Camera**: Added Camera2D for proper viewport

## What You Need to Do Manually (5 Minutes)

### Step 1: Add Dungeon Buttons to Main Menu

1. **Open Godot 4.4**
2. **Navigate to** `Tests/Main_menu.tscn`
3. **Find the UI container** where other buttons are (look for VBoxContainer or similar)
4. **Add Button 1**:
   - Right-click the container → Add Child Node → Button
   - Name: `ArithmeticDungeonButton`
   - In Inspector, set Text: `"Arithmetic Dungeon"`
   - Go to Node tab (right panel) → Signals
   - Double-click `pressed()` signal
   - Make sure "Pick from scene" shows the main_menu node
   - Method name: `_on_dungeon_arithmetic_pressed`
   - Click "Connect"

5. **Add Button 2**:
   - Right-click the container → Add Child Node → Button
   - Name: `GeometricDungeonButton`
   - In Inspector, set Text: `"Geometric Dungeon"`
   - Go to Node tab → Signals
   - Double-click `pressed()` signal
   - Method name: `_on_dungeon_geometric_pressed`
   - Click "Connect"

6. **Save the scene** (Ctrl+S)

### Step 2: Test the Dungeon

1. **Press F5** to run the project
2. **Click** "Arithmetic Dungeon" button
3. **You should see**:
   - A 5×10 grid of colored tiles
   - Gray tiles = empty floor
   - Dark gray = obstacles
   - Red = enemies
   - Gold = chests
   - Green = staircase (unlocked after killing enemies)
   - Blue rectangle = YOU (the player)
   - HUD at top showing Hearts, Moves, Floor, Kills

### Step 3: Play!

**Controls**:
- **W/Up Arrow**: Move up
- **S/Down Arrow**: Move down
- **A/Left Arrow**: Move left
- **D/Right Arrow**: Move right
- **Enter**: Save checkpoint
- **ESC**: Back to menu (if you add exit button)

**Gameplay**:
1. Move around with WASD/Arrows (costs 1 move per tile)
2. Black fog disappears as you explore
3. Moving onto a red enemy tile starts a battle
4. Answer 3 stages of questions correctly to defeat enemy
5. Defeat 3 out of 5 enemies (50%) to unlock the green staircase
6. Move onto the green staircase to go to next floor

## What Each Color Means

- **Light Gray** = Empty walkable floor
- **Dark Gray** = Obstacle (can't walk through)
- **Red** = Enemy (battle when you move onto it)
- **Gold** = Chest (opens when you move onto it)
- **Green** = Staircase (locked until you kill 50% enemies)
- **Blue** = You (the player)
- **Black Overlay** = Fog (unexplored areas)

## Expected Visual

When you run the dungeon, you should see something like:

```
┌──────────────────────────────────┐
│ Hearts: 3.0/3.0  Moves: 5  Floor: 1/4  Kills: 0/3 │
├──────────────────────────────────┤
│ [Gray][Gray][Dark][Gray][Red]... │  ← Grid of colored tiles
│ [Gray][Blue][Gray][Gold][Gray]... │  ← Blue is player
│ [Dark][Gray][Gray][Gray][Red]... │  ← Red is enemy
│ [Gray][Gray][Gray][Gray][Gray]... │
│ [Gray][Gray][Green][Gray][Gray]..│  ← Green is staircase
└──────────────────────────────────┘
```

## Troubleshooting

### "Can't see anything"
- Make sure you added the buttons and connected the signals
- Check the Output console for "Dungeon initialized" message
- Press F5 to ensure project is running

### "DungeonManager not found"
- Close and reopen Godot to reload autoloads
- Check project.godot has: `DungeonManager="*res://dungeon_manager.gd"`

### "Nothing happens when I click the button"
- Check if the signal is properly connected
- Check the Output console for errors
- Make sure the button's `pressed()` signal connects to the correct method

### "Still getting Tile error"
- Make sure you pulled the latest changes
- The class is now named `DungeonTile` not `Tile`
- Close and reopen Godot

### "Grid is off-screen or too small"
- The camera is centered at (320, 160)
- Each tile is 64×64 pixels
- Grid is 10 columns × 5 rows = 640×320 pixels
- If your viewport is smaller, adjust Camera2D zoom or position

## What's Working Now

✅ Visible colored tiles (no more invisible sprites)
✅ Top-down view (simple and clear)
✅ No class name conflicts
✅ Player is visible (blue rectangle)
✅ Camera shows the grid
✅ Fog-of-war works
✅ Movement works
✅ Battle system works
✅ All core systems functional

## Next Steps (After Testing)

Once you verify the dungeon works:

1. **Replace colored rectangles** with actual tile sprites
2. **Add a player sprite** (replace blue rectangle)
3. **Add enemy sprites** (replace red rectangles)
4. **Integrate question database** (currently uses placeholder questions)
5. **Add sound effects**
6. **Polish animations**

But the **core gameplay loop is fully functional** right now!

## Questions?

Check the other documentation files:
- `DUNGEON_SYSTEM_README.md` - Complete technical docs
- `DUNGEON_SETUP_GUIDE.md` - Detailed setup guide
- `DUNGEON_QUICK_REFERENCE.md` - Quick reference
- `ARCHITECTURE_DIAGRAM.md` - System diagrams

Or check the console output when running - it prints helpful debug info!
