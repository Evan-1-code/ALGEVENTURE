# AlgeVenture

An educational pixel RPG game to improve algebra proficiency for Grade 11 STEM students. Built with Godot.

---

## 📂 Folder Structure

/addons/ # Godot plugins (if any)
/assets/ # Images, sounds, animations
/characters/ # NPCs and player scenes/scripts
/scenes/ # Main scenes (main menu, town, battle, etc.)
/scripts/ # Global and utility scripts
/ui/ # UI elements and scenes
/tests/ # Test scenes or scripts
README.md
.gitignore

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
