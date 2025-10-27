extends Node

## DungeonManager - Autoload singleton for managing dungeon state
## Handles dungeon config selection, save/load, and respawning

signal dungeon_loaded(dungeon_type: String)
signal floor_changed(floor_number: int)
signal checkpoint_saved()

var current_config: DungeonConfig
var player_state: PlayerState
var current_dungeon_type: String = ""
var save_file_path: String = "user://dungeon_save.json"

# Preload configs
var arithmetic_config: DungeonConfig
var geometric_config: DungeonConfig

func _ready() -> void:
	_initialize_configs()
	player_state = PlayerState.new()

func _initialize_configs() -> void:
	# Load configs from resource files
	var arithmetic_path = "res://data/dungeon/arithmetic_config.tres"
	var geometric_path = "res://data/dungeon/geometric_config.tres"
	
	if ResourceLoader.exists(arithmetic_path):
		arithmetic_config = load(arithmetic_path)
	else:
		# Fallback to creating default configs
		arithmetic_config = DungeonConfig.new()
		arithmetic_config.dungeon_type = "arithmetic"
		arithmetic_config.dungeon_name = "Arithmetic Depths"
		arithmetic_config.max_floors = 4
	
	if ResourceLoader.exists(geometric_path):
		geometric_config = load(geometric_path)
	else:
		geometric_config = DungeonConfig.new()
		geometric_config.dungeon_type = "geometric"
		geometric_config.dungeon_name = "Geometric Labyrinth"
		geometric_config.max_floors = 4

func load_dungeon(dungeon_type: String) -> void:
	current_dungeon_type = dungeon_type
	
	match dungeon_type:
		"arithmetic":
			current_config = arithmetic_config
		"geometric":
			current_config = geometric_config
		_:
			current_config = arithmetic_config
			current_dungeon_type = "arithmetic"
	
	# Reset player state for new dungeon
	player_state = PlayerState.new()
	player_state.dungeon_type = current_dungeon_type
	player_state.hearts = current_config.starting_hearts
	player_state.max_hearts = current_config.starting_hearts
	player_state.moves_left = current_config.starting_moves
	
	dungeon_loaded.emit(current_dungeon_type)
	
	# Load the dungeon scene
	get_tree().change_scene_to_file("res://scenes/dungeon/dungeon_scene.tscn")

func advance_floor() -> void:
	player_state.current_floor += 1
	player_state.kills_this_floor = 0
	player_state.reset_moves(current_config.starting_moves)
	floor_changed.emit(player_state.current_floor)
	save_checkpoint()

func save_checkpoint() -> void:
	var save_data = {
		"dungeon_type": current_dungeon_type,
		"player_state": player_state.to_dict(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		checkpoint_saved.emit()
		print("Checkpoint saved: Floor ", player_state.current_floor)

func load_checkpoint() -> bool:
	if not FileAccess.file_exists(save_file_path):
		return false
	
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse save file")
		return false
	
	var save_data = json.get_data()
	
	# Load dungeon type
	current_dungeon_type = save_data.get("dungeon_type", "arithmetic")
	match current_dungeon_type:
		"arithmetic":
			current_config = arithmetic_config
		"geometric":
			current_config = geometric_config
		_:
			current_config = arithmetic_config
	
	# Load player state
	player_state = PlayerState.new()
	player_state.from_dict(save_data.get("player_state", {}))
	
	print("Checkpoint loaded: Floor ", player_state.current_floor)
	return true

func has_save() -> bool:
	return FileAccess.file_exists(save_file_path)

func delete_save() -> void:
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)

func get_current_config() -> DungeonConfig:
	return current_config

func get_player_state() -> PlayerState:
	return player_state

func is_dungeon_complete() -> bool:
	return player_state.current_floor >= current_config.max_floors

func respawn_at_checkpoint() -> void:
	# Reset to last checkpoint (current floor)
	player_state.hearts = current_config.starting_hearts
	player_state.moves_left = current_config.starting_moves
	player_state.kills_this_floor = 0
	# Reload the current floor
	get_tree().reload_current_scene()
