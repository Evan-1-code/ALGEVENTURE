# Dungeon System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ALGEVENTURE - DUNGEON MODE                   │
│                         System Architecture                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          AUTOLOAD LAYER                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    DungeonManager                            │   │
│  │  • Global state management                                   │   │
│  │  • Config loading (Arithmetic/Geometric)                     │   │
│  │  • Save/Load checkpoints                                     │   │
│  │  • Floor advancement                                         │   │
│  │  • Respawn logic                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │DungeonConfig │  │ PlayerState  │  │  EnemyData   │              │
│  │  (Resource)  │  │   (Class)    │  │   (Class)    │              │
│  │              │  │              │  │              │              │
│  │ • Grid size  │  │ • Position   │  │ • Type       │              │
│  │ • Enemies    │  │ • Hearts     │  │ • HP         │              │
│  │ • Items      │  │ • Inventory  │  │ • Rewards    │              │
│  │ • Difficulty │  │ • XP/Level   │  │ • Position   │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         LOGIC LAYER                                  │
│  ┌────────────────────┐  ┌────────────────────┐                    │
│  │ DungeonGenerator   │  │ PlayerController   │                    │
│  │                    │  │                    │                    │
│  │ • Floor generation │  │ • Movement         │                    │
│  │ • Obstacle place   │  │ • Fog-of-war       │                    │
│  │ • Entity spawning  │  │ • Move budget      │                    │
│  │ • Connectivity     │  │ • Interactions     │                    │
│  └────────────────────┘  └────────────────────┘                    │
│                                    ↓                                 │
│  ┌────────────────────┐  ┌────────────────────┐                    │
│  │  BattleManager     │  │    Inventory       │                    │
│  │                    │  │                    │                    │
│  │ • 3-stage battles  │  │ • Item management  │                    │
│  │ • Question flow    │  │ • Chest loot       │                    │
│  │ • Damage calc      │  │ • Item effects     │                    │
│  │ • Calculator/Hints │  │ • Equipment        │                    │
│  └────────────────────┘  └────────────────────┘                    │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      DungeonScene                            │   │
│  │  (Main Controller - Orchestrates all systems)                │   │
│  │                                                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │   │
│  │  │    Tile     │  │  DungeonHUD │  │BattleOverlay│         │   │
│  │  │             │  │             │  │             │         │   │
│  │  │ • Visual    │  │ • Hearts    │  │ • Questions │         │   │
│  │  │ • Fog       │  │ • Moves     │  │ • Choices   │         │   │
│  │  │ • Click     │  │ • Floor     │  │ • Answer    │         │   │
│  │  │ • Type      │  │ • Inventory │  │ • Buttons   │         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════
                           SIGNAL FLOW
═══════════════════════════════════════════════════════════════════════

User Input (WASD/Click)
    ↓
PlayerController.move_to(target)
    ↓ emit: moved(position)
DungeonScene._on_player_moved()
    ├─→ Update fog visuals on tiles
    ├─→ Check tile content
    └─→ Update HUD
    ↓ emit: enemy_encountered(enemy)
BattleManager.start_battle()
    ↓ emit: battle_started(enemy)
BattleOverlay.show()
    ↓ User submits answer
BattleManager.submit_stage_answer()
    ├─→ Correct: Advance stage / Damage enemy
    └─→ Wrong: Damage player
    ↓ emit: battle_ended(victory)
DungeonScene._on_battle_ended()
    ├─→ Victory: Restore moves, check staircase
    └─→ Defeat: Game over, respawn
    ↓
Update HUD, Update grid visuals

═══════════════════════════════════════════════════════════════════════
                         GAMEPLAY LOOP
═══════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────┐
│ 1. Floor Start                                                │
│    • Generate grid (5×10)                                     │
│    • Place obstacles (10-18%)                                 │
│    • Spawn 5 enemies, 1-3 chests, staircase                  │
│    • Reset fog-of-war                                         │
│    • Set moves to 5                                           │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│ 2. Exploration Phase                                          │
│    • Player moves (WASD)                                      │
│    • Fog reveals adjacent tiles                               │
│    • Discovers enemies/chests/staircase                       │
│    • Uses 1 move per tile                                     │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│ 3. Encounter                                                  │
│    ├─→ Enemy: Start battle                                   │
│    ├─→ Chest: Get loot, update inventory                     │
│    └─→ Staircase: Check if unlocked                          │
└──────────────────────────────────────────────────────────────┘
                          ↓ (if enemy)
┌──────────────────────────────────────────────────────────────┐
│ 4. Battle Phase                                               │
│    Stage 1 (GIVEN): Identify information [MCQ]                │
│         ↓ correct                                             │
│    Stage 2 (FORMULA): Choose formula [MCQ]                    │
│         ↓ correct                                             │
│    Stage 3 (ANSWER): Enter answer [Numeric]                   │
│         ↓ correct                                             │
│    Defeat enemy → +XP, restore moves to 5                     │
│                                                               │
│    Wrong answer → Take damage (1.0 or 0.5 with armor)        │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│ 5. Progress Check                                             │
│    • Kills ≥ 50% of enemies? → Unlock staircase              │
│    • Moves = 0? → Game over, respawn                          │
│    • Hearts = 0? → Game over, respawn                         │
│    • Reach staircase? → Advance floor                         │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│ 6. Floor Complete                                             │
│    • Save checkpoint                                          │
│    • Advance to next floor (repeat from step 1)              │
│    • Or complete dungeon (4 floors)                           │
└──────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════
                        CONFIGURATION FLOW
═══════════════════════════════════════════════════════════════════════

Main Menu Button Click
    ↓
DungeonManager.load_dungeon("arithmetic")
    ↓
Load config: data/dungeon/arithmetic_config.tres
    ↓
Initialize PlayerState (hearts, moves, inventory)
    ↓
Change scene: scenes/dungeon/dungeon_scene.tscn
    ↓
DungeonScene._ready()
    ↓
Create DungeonGenerator(config)
    ↓
Generate floor layout
    ↓
Initialize PlayerController, BattleManager, Inventory
    ↓
Render grid with tiles
    ↓
Ready to play!

═══════════════════════════════════════════════════════════════════════
                          FILE STRUCTURE
═══════════════════════════════════════════════════════════════════════

res://
├── dungeon_manager.gd ..................... Autoload singleton
├── project.godot .......................... Autoload registration
├── Tests/
│   └── main_menu.gd ....................... Dungeon button handlers
├── data/
│   └── dungeon/
│       ├── arithmetic_config.tres ......... Arithmetic settings
│       └── geometric_config.tres .......... Geometric settings
├── scenes/
│   └── dungeon/
│       ├── dungeon_scene.tscn ............. Main dungeon scene
│       └── tile.tscn ...................... Tile prefab
├── scripts/
│   ├── dungeon/
│   │   ├── battle_manager.gd .............. Combat system
│   │   ├── dungeon_config.gd .............. Config resource
│   │   ├── dungeon_generator.gd ........... Procedural gen
│   │   ├── dungeon_scene.gd ............... Scene controller
│   │   ├── enemy_data.gd .................. Enemy model
│   │   ├── inventory.gd ................... Items & loot
│   │   ├── player_controller.gd ........... Movement & fog
│   │   ├── player_state.gd ................ Player data
│   │   └── tile.gd ........................ Individual tile
│   └── ui/
│       ├── battle_overlay.gd .............. Battle UI
│       └── dungeon_hud.gd ................. HUD display
└── Documentation/
    ├── DUNGEON_SYSTEM_README.md ........... Full docs
    ├── DUNGEON_SETUP_GUIDE.md ............. Setup guide
    ├── DUNGEON_QUICK_REFERENCE.md ......... Quick ref
    └── IMPLEMENTATION_SUMMARY.md .......... This summary

═══════════════════════════════════════════════════════════════════════
```
