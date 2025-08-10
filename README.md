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

| Folder / File               | Owner(s)      | Notes                                           |
| --------------------------- | ------------- | ----------------------------------------------- |
| `Scenes/MainMenu/`          | Main Menu Dev | Handles menu UI, buttons, background            |
| `Scenes/Player/Player.tscn` | Movement Dev  | Owns Player scene & base script                 |
| `Scripts/Player/Player.gd`  | Movement Dev  | Core movement logic – only owner edits          |
| `Scenes/NPCs/`              | NPC Dev(s)    | NPC visuals & interaction triggers              |
| `Scripts/NPCs/`             | NPC Dev(s)    | Dialogue triggers, interaction logic            |
| `Scenes/Battle/`            | Battle Dev(s) | Battle scene, UI, and logic                     |
| `Scripts/Battle/`           | Battle Dev(s) | Battle manager, HP/XP logic                     |
| `Assets/Sprites/`           | Artist(s)     | Sprite sheets, textures                         |
| `Assets/Sound/`             | Audio Dev(s)  | Music, sound effects                            |
| `Globals/`                  | Lead Dev      | Autoloads (GameState, SaveManager, etc.)        |
| `Contents/`                 | Writer(s)     | Dialogue files, story scripts                   |
| `Tests/`                    | Any           | Temporary testing files, can be deleted anytime |

2. Editing Rules
Export Variables: Programmers should use @export so artists can assign assets without editing code.

Scene Instancing: If adding new components, make them in separate .tscn files and instance into main scenes.

One Feature per Branch: Always branch off dev (or another feature branch if it depends on it).

Commit Messages: Be clear — e.g., Add NPC interaction script not stuff done.

Pull Before Push: Always pull before push to merge locally first.

3. Example Workflow
Player Animation Example:
Movement Dev: Creates Player.tscn + Player.gd with placeholder sprite and export variable @export var anim_player.
Animator: Opens Player.tscn, adds AnimationPlayer node, assigns anim_player variable, imports animations.
Dialogue Dev: Creates PlayerDialogue.tscn and instances it in Player.tscn without touching movement code.

4. Communication
Use Discord channel #dev-changes to announce when you:
Create new files
Rename/move files
Edit someone else’s file (with permission)
Ping the file owner if you’re unsure.


