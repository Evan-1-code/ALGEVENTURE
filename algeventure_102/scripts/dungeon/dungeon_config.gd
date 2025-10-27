extends Resource
class_name DungeonConfig

## Configuration for dungeon generation and gameplay

@export_group("Grid Settings")
@export var rows: int = 5
@export var cols: int = 10
@export var tile_size: int = 64

@export_group("Spawn Settings")
@export var spawn_col: int = 9  # Middle-right tile (column 9)
@export var spawn_row: int = 2  # Middle row (row 2, 0-indexed)
@export var staircase_min_distance: int = 5  # Manhattan distance from player spawn

@export_group("Entity Counts")
@export var enemy_count: int = 5
@export var chest_count_min: int = 1
@export var chest_count_max: int = 3
@export var obstacle_percentage_min: float = 0.10
@export var obstacle_percentage_max: float = 0.18

@export_group("Gameplay")
@export var starting_moves: int = 5
@export var reveal_radius: int = 1
@export var required_kill_percentage: float = 0.5  # 50% of enemies must be defeated
@export var boots_move_bonus: int = 2

@export_group("Player Stats")
@export var starting_hearts: float = 3.0
@export var damage_per_wrong_answer: float = 1.0
@export var damage_with_armor: float = 0.5

@export_group("Dungeon Type")
@export_enum("arithmetic", "geometric") var dungeon_type: String = "arithmetic"
@export var dungeon_name: String = "Arithmetic Dungeon"
@export var max_floors: int = 4

func get_required_kills() -> int:
	return ceili(enemy_count * required_kill_percentage)
