# Visual Reference - What You Should See

## Main Menu (After Adding Buttons)

```
┌─────────────────────────────────────┐
│         ALGEVENTURE                  │
│                                      │
│   [Play]                             │
│   [Settings]                         │
│   [Arithmetic Dungeon]  ← ADD THIS  │
│   [Geometric Dungeon]   ← ADD THIS  │
│   [Quit]                             │
│                                      │
└─────────────────────────────────────┘
```

## Dungeon View (What You'll See)

```
┌─────────────────────────────────────────────────────────────────┐
│ Hearts: 3.0/3.0    Moves: 5    Floor: 1/4    Kills: 0/3         │ ← HUD
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ░ ░ ░ ░ ░ ░ ░ ░ ░ ░  ← Black fog (unexplored)                │
│  ░ ░ ░ ░ ░ ░ ░ ░ ░ ░                                           │
│  ░ ░ ▓ □ □ □ ◆ □ □ ■  ← Revealed area                         │
│  ░ ░ □ ■ □ ◆ □ □ ▓ □     ▓ = Obstacle (dark gray)            │
│  ░ ░ □ □ □ □ □ □ □ □     □ = Empty (light gray)              │
│                              ■ = Enemy (red)                     │
│  Legend:                     ◆ = Chest (gold)                   │
│  ■ = Player (blue)           ★ = Staircase (green)             │
│  ■ = Enemy (red)             ░ = Fog (black)                   │
│  ◆ = Chest (gold)                                               │
│  ★ = Staircase (green)                                          │
│  ▓ = Obstacle (dark)                                            │
│  □ = Floor (light gray)                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Actual Colors You'll See

### Tiles (64×64 pixel colored rectangles):

1. **Empty Floor Tile**
   ```
   ┌────────┐
   │        │  Color: Light Gray (RGB: 204, 204, 204)
   │        │  Walkable: Yes
   └────────┘
   ```

2. **Obstacle Tile**
   ```
   ┌────────┐
   │ ████   │  Color: Dark Gray (RGB: 77, 77, 77)
   │ ████   │  Walkable: No
   └────────┘
   ```

3. **Enemy Tile**
   ```
   ┌────────┐
   │  👹    │  Color: Red (RGB: 230, 51, 51)
   │        │  Walkable: Yes (triggers battle)
   └────────┘
   ```

4. **Chest Tile**
   ```
   ┌────────┐
   │  💰    │  Color: Gold (RGB: 255, 204, 51)
   │        │  Walkable: Yes (opens chest)
   └────────┘
   ```

5. **Staircase Tile**
   ```
   ┌────────┐
   │  ⬇️     │  Color: Green (RGB: 51, 230, 51)
   │        │  Walkable: Yes (when unlocked)
   └────────┘
   ```

6. **Player Marker**
   ```
   ┌────────┐
   │  ■■■   │  Color: Blue (RGB: 51, 128, 255)
   │  ■■■   │  Size: 60×60 (slightly smaller than tile)
   └────────┘
   ```

7. **Fog Overlay**
   ```
   ┌────────┐
   │████████│  Color: Black with 80% opacity
   │████████│  Disappears when you explore nearby
   └────────┘
   ```

## Battle Screen (When You Fight Enemy)

```
┌─────────────────────────────────────────────────────────────┐
│ [Dark Background - 70% opacity covers dungeon]              │
│                                                              │
│   ┌─────────────────────────────────────────────────┐      │
│   │ Enemy: Slime (HP: 1)                             │      │
│   │                                                   │      │
│   │ Question: What is the given in this problem:     │      │
│   │ "Solve for x: 2x + 5 = 15"?                     │      │
│   │                                                   │      │
│   │  [ ] 2x + 5 = 15  ← Click to select              │      │
│   │  [ ] x = 5                                        │      │
│   │  [ ] 2x                                           │      │
│   │  [ ] 15                                           │      │
│   │                                                   │      │
│   │  [Calculator] [Use Scroll] [Hint]                │      │
│   └─────────────────────────────────────────────────┘      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Grid Layout (10 columns × 5 rows)

```
Column: 0    1    2    3    4    5    6    7    8    9
Row 0: [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ]
Row 1: [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ]
Row 2: [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [■ ]  ← Player starts here
Row 3: [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ]
Row 4: [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ] [  ]

Each tile is 64×64 pixels
Total grid size: 640×320 pixels
Player spawns at column 9, row 2 (middle-right)
```

## Camera View

```
  Camera Position: (320, 160)
       ↓
   ┌───────────────────────┐
   │                       │
   │    Viewport shows     │
   │    entire 10×5 grid   │
   │                       │
   └───────────────────────┘
```

## Movement Example

```
Before Move:              After Move Right:
┌─────────┐              ┌─────────┐
│ □ □ ■ □ │              │ □ □ □ ■ │
│ □ □ □ □ │              │ □ □ □ □ │
└─────────┘              └─────────┘
   ↑                        ↑
Player at (2,0)          Player at (3,0)
                         Fog reveals around new position
```

## Fog Reveal Pattern (Radius 1)

```
When player moves, reveals 3×3 area:

    ░ ░ ░ ░         □ □ □ ░
    ░ ░ ░ ░   →     □ ■ □ ░
    ░ ░ ░ ░         □ □ □ ░
    ░ ░ ░ ░         ░ ░ ░ ░

Legend:
■ = Player position
□ = Revealed tiles
░ = Still fogged
```

## Progress Example

```
Floor 1 Start:
├─ Kills: 0/3
├─ Moves: 5
└─ Staircase: 🔒 Locked

After killing 3 enemies:
├─ Kills: 3/3
├─ Moves: 5 (restored after each kill)
└─ Staircase: ✅ Unlocked (green)
```

## Tips for Visual Debugging

If you can't see tiles:
1. Check the Output console for "Dungeon initialized" message
2. Look for colored rectangles 64×64 pixels
3. Player (blue square) should be at right side of grid
4. Press WASD to move - you should see the blue square move
5. Black fog should disappear as you move

If tiles are too small:
- Open dungeon_scene.tscn
- Select Camera2D node
- Increase zoom to 2 or 3

If grid is off-center:
- Open dungeon_scene.tscn
- Select Camera2D node
- Adjust position to center the view
