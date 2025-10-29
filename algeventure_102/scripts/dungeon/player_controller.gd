extends Node2D
class_name PlayerController

## Handles player movement, fog-of-war, and move budget

signal moved(new_position: Vector2i)
signal move_depleted()
signal enemy_encountered(enemy: EnemyData)
signal chest_opened(position: Vector2i)
signal staircase_reached()

@export var config: DungeonConfig
@export var move_duration: float = 0.1  # Movement animation duration

var player_state: PlayerState
var current_position: Vector2i
var is_moving: bool = false
var fog_of_war: Dictionary = {}  # pos -> bool (revealed or not)
var generator: DungeonGenerator
var player_visual: ColorRect

func _ready() -> void:
	if not player_state:
		player_state = PlayerState.new()
	if not config:
		config = DungeonConfig.new()
	
	# Create visual representation
	_create_player_visual()

func _create_player_visual() -> void:
	player_visual = ColorRect.new()
	player_visual.size = Vector2(60, 60)
	player_visual.position = Vector2(2, 2)  # Small offset for visibility
	player_visual.color = Color(0.2, 0.5, 1.0, 1.0)  # Blue
	add_child(player_visual)

func initialize(gen: DungeonGenerator, state: PlayerState) -> void:
	generator = gen
	player_state = state
	current_position = generator.player_spawn
	player_state.pos = current_position
	_reset_fog_of_war()
	_reveal_fog_around_position(current_position)

func _reset_fog_of_war() -> void:
	fog_of_war.clear()
	for y in range(config.rows):
		for x in range(config.cols):
			fog_of_war[Vector2i(x, y)] = false

func can_move_to(target: Vector2i) -> bool:
	if not _is_valid_position(target):
		return false
	
	var tile = generator.get_tile(target)
	if tile == DungeonGenerator.TileType.OBSTACLE:
		return false
	
	return true

func move_to(target: Vector2i) -> bool:
	if is_moving:
		return false
	
	if not can_move_to(target):
		return false
	
	# Check if player has moves left
	if not player_state.use_move():
		move_depleted.emit()
		return false
	
	# Animate movement
	is_moving = true
	var target_world_pos = _grid_to_world(target)
	var tween = create_tween()
	tween.tween_property(self, "position", target_world_pos, move_duration)
	await tween.finished
	
	current_position = target
	player_state.pos = current_position
	is_moving = false
	
	# Reveal fog
	_reveal_fog_around_position(current_position)
	
	# Check what's at the new position
	_check_tile_interactions(current_position)
	
	moved.emit(current_position)
	return true

func _reveal_fog_around_position(pos: Vector2i) -> void:
	var radius = config.reveal_radius
	if player_state.inventory.get("torch", 0) > 0:
		radius = 2  # Torch expands vision
	
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var check_pos = Vector2i(pos.x + dx, pos.y + dy)
			if _is_valid_position(check_pos):
				fog_of_war[check_pos] = true

func is_tile_revealed(pos: Vector2i) -> bool:
	return fog_of_war.get(pos, false)

func _check_tile_interactions(pos: Vector2i) -> void:
	var tile = generator.get_tile(pos)
	
	match tile:
		DungeonGenerator.TileType.ENEMY:
			var enemy = generator.get_enemy_at_position(pos)
			if enemy and not enemy.is_defeated:
				enemy_encountered.emit(enemy)
		
		DungeonGenerator.TileType.CHEST:
			chest_opened.emit(pos)
		
		DungeonGenerator.TileType.STAIRCASE:
			staircase_reached.emit()

func can_interact_with_enemy(enemy_pos: Vector2i) -> bool:
	# Can interact with enemy if within 1 tile (including diagonals)
	var dist = _manhattan_distance(current_position, enemy_pos)
	return dist <= 2  # Manhattan distance of 2 allows diagonals

func restore_moves() -> void:
	player_state.reset_moves(config.starting_moves)

func add_move_bonus(bonus: int) -> void:
	player_state.moves_left += bonus

func _is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < config.cols and pos.y >= 0 and pos.y < config.rows

func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Convert grid position to world position
	# This is a simple implementation; adjust based on your isometric setup
	return Vector2(grid_pos.x * config.tile_size, grid_pos.y * config.tile_size)

func get_adjacent_positions(pos: Vector2i) -> Array[Vector2i]:
	var adjacent: Array[Vector2i] = []
	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	
	for dir in directions:
		var neighbor = pos + dir
		if _is_valid_position(neighbor):
			adjacent.append(neighbor)
	
	return adjacent
