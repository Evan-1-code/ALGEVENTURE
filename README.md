# AlgeVenture

An educational pixel RPG game to improve algebra proficiency for Grade 11 STEM students. Built with Godot.

---

## 📂 Folder Structure

<pre><code>
res://
│
├── Assets/                 # Raw art, sounds, music, etc.
│   ├── Sound/
│   ├── Fonts/
│   ├── Sprites/
│   ├── Tilesets/
│
├── Characters/            # Player & NPCs
│   ├── Player/
│   └── NPCs/
│
├── Scenes/                # Main game areas
│   ├── MainMenu/
│   │   └── MainMenu.tscn
│   ├── Map/
│   │   ├── Town_Map.tscn
│   │   └── Shop.tscn
│   ├── Battle/
│   │   └── BattleScene.tscn
│   └── Dialogue/
│   |  └── DialogueBox.tscn
│   |__  
├── Scripts/               # All game logic scripts
│   |
│   ├── Systems/
│   ├── Characters/
│   └── Utilities/
│
├── UI/                    # Reusable UI components
│   └── HUD/
│
├── Globals/               # Autoloads (GameState, SaveManager, etc.)
│   └── GameState.gd
│
├── Contents/             # Dialogue files (JSON or script-based)
│   └── npc_intro.dialogue
│   |__ Problems
├── Tests/                 # Temporary or test files
│
└── main.gd                # Optional: main logic
</code></pre>

## 🌿 Branch Workflow

> All feature branches must start from the `dev` branch.

### Main Branches
- `main` — Stable production version
- `dev` — Integration branch for testing features

### Feature Branches
Create from `dev`:
- `feature/battle-system`
- `feature/algebra-npc`
- `feature/formula-forge`

---

## 🧪 How to Contribute (via GitHub Desktop)

1. Switch to `dev` branch
2. Create a new branch: `feature/your-task`
3. Work in Godot
4. Commit changes with clear messages
5. Push your branch
6. On GitHub, open a Pull Request **into `dev`**
7. Wait for approval/merge

---

## ✅ Naming Conventions

- Branch: `feature/scene-name` or `fix/bug-name`
- Commits: `feat: added NPC`, `fix: corrected math issue`

---

## 🛡️ Guidelines

- Don’t commit `.import/`, `.godot/`, or `.log` files
- Always pull before starting work
- Keep commits small and meaningful
- Use PRs for **everything**
