extends Node
class_name DungeonGenerator

## Procedural dungeon floor generator
## Handles grid generation, obstacle placement, entity spawning

signal generation_complete()

enum TileType {
	EMPTY,
	OBSTACLE,
	ENEMY,
	CHEST,
	STAIRCASE,
	PLAYER
}

var config: DungeonConfig
var grid: Array[Array] = []
var enemies: Array[EnemyData] = []
var chest_positions: Array[Vector2i] = []
var staircase_position: Vector2i = Vector2i(-1, -1)
var player_spawn: Vector2i = Vector2i.ZERO

func _init(dungeon_config: DungeonConfig = null) -> void:
	if dungeon_config:
		config = dungeon_config
	else:
		config = DungeonConfig.new()

func generate_floor() -> void:
	grid.clear()
	enemies.clear()
	chest_positions.clear()
	staircase_position = Vector2i(-1, -1)
	
	# Initialize empty grid
	_initialize_grid()
	
	# Set player spawn
	player_spawn = Vector2i(config.spawn_col, config.spawn_row)
	_set_tile(player_spawn, TileType.PLAYER)
	
	# Place obstacles (ensuring connectivity)
	_place_obstacles()
	
	# Place enemies
	_place_enemies()
	
	# Place chests
	_place_chests()
	
	# Place staircase (outside radius from player)
	_place_staircase()
	
	generation_complete.emit()

func _initialize_grid() -> void:
	grid = []
	for y in range(config.rows):
		var row: Array[int] = []
		row.resize(config.cols)
		for x in range(config.cols):
			row[x] = TileType.EMPTY
		grid.append(row)

func _place_obstacles() -> void:
	var total_tiles = config.rows * config.cols
	var obstacle_count_min = int(total_tiles * config.obstacle_percentage_min)
	var obstacle_count_max = int(total_tiles * config.obstacle_percentage_max)
	var obstacle_count = randi_range(obstacle_count_min, obstacle_count_max)
	
	var placed = 0
	var attempts = 0
	var max_attempts = obstacle_count * 10
	
	while placed < obstacle_count and attempts < max_attempts:
		attempts += 1
		var pos = _get_random_empty_position()
		if pos == Vector2i(-1, -1):
			break
		
		# Don't place obstacle too close to spawn
		if _manhattan_distance(pos, player_spawn) < 3:
			continue
		
		# Temporarily place obstacle and check connectivity
		_set_tile(pos, TileType.OBSTACLE)
		if _check_connectivity():
			placed += 1
		else:
			_set_tile(pos, TileType.EMPTY)

func _place_enemies() -> void:
	enemies.clear()
	for i in range(config.enemy_count):
		var pos = _get_random_empty_position()
		if pos == Vector2i(-1, -1):
			break
		
		var enemy = EnemyData.new()
		enemy.enemy_id = i
		enemy.position = pos
		enemy.enemy_type = _get_enemy_type_for_floor()
		enemy.hp = _get_enemy_hp_for_type(enemy.enemy_type)
		enemy.difficulty_tier = _get_difficulty_tier()
		enemy.xp_reward = 10 + (enemy.difficulty_tier * 5)
		enemy.taunts = _get_enemy_taunts(enemy.enemy_type)
		
		enemies.append(enemy)
		_set_tile(pos, TileType.ENEMY)

func _place_chests() -> void:
	chest_positions.clear()
	var chest_count = randi_range(config.chest_count_min, config.chest_count_max)
	
	for i in range(chest_count):
		var pos = _get_random_empty_position()
		if pos == Vector2i(-1, -1):
			break
		
		chest_positions.append(pos)
		_set_tile(pos, TileType.CHEST)

func _place_staircase() -> void:
	var attempts = 0
	var max_attempts = 100
	
	while attempts < max_attempts:
		attempts += 1
		var pos = _get_random_empty_position()
		if pos == Vector2i(-1, -1):
			continue
		
		# Must be outside minimum distance from player spawn
		if _manhattan_distance(pos, player_spawn) >= config.staircase_min_distance:
			staircase_position = pos
			_set_tile(pos, TileType.STAIRCASE)
			return
	
	# Fallback: place at furthest empty tile
	var furthest_pos = Vector2i(-1, -1)
	var max_dist = 0
	for y in range(config.rows):
		for x in range(config.cols):
			if grid[y][x] == TileType.EMPTY:
				var dist = _manhattan_distance(Vector2i(x, y), player_spawn)
				if dist > max_dist:
					max_dist = dist
					furthest_pos = Vector2i(x, y)
	
	if furthest_pos != Vector2i(-1, -1):
		staircase_position = furthest_pos
		_set_tile(furthest_pos, TileType.STAIRCASE)

func _get_random_empty_position() -> Vector2i:
	var empty_tiles: Array[Vector2i] = []
	for y in range(config.rows):
		for x in range(config.cols):
			if grid[y][x] == TileType.EMPTY:
				empty_tiles.append(Vector2i(x, y))
	
	if empty_tiles.is_empty():
		return Vector2i(-1, -1)
	
	return empty_tiles[randi() % empty_tiles.size()]

func _check_connectivity() -> bool:
	# Simple flood-fill from player spawn to check if all non-obstacle tiles are reachable
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [player_spawn]
	visited[player_spawn] = true
	var reachable_count = 1
	
	while not queue.is_empty():
		var current = queue.pop_front()
		
		# Check 4 directions (not 8 for simplicity)
		var neighbors = [
			Vector2i(current.x + 1, current.y),
			Vector2i(current.x - 1, current.y),
			Vector2i(current.x, current.y + 1),
			Vector2i(current.x, current.y - 1)
		]
		
		for neighbor in neighbors:
			if _is_valid_position(neighbor) and not visited.has(neighbor):
				if grid[neighbor.y][neighbor.x] != TileType.OBSTACLE:
					visited[neighbor] = true
					queue.append(neighbor)
					reachable_count += 1
	
	# Count non-obstacle tiles
	var non_obstacle_count = 0
	for y in range(config.rows):
		for x in range(config.cols):
			if grid[y][x] != TileType.OBSTACLE:
				non_obstacle_count += 1
	
	return reachable_count == non_obstacle_count

func _is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < config.cols and pos.y >= 0 and pos.y < config.rows

func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _set_tile(pos: Vector2i, tile_type: TileType) -> void:
	if _is_valid_position(pos):
		grid[pos.y][pos.x] = tile_type

func get_tile(pos: Vector2i) -> TileType:
	if _is_valid_position(pos):
		return grid[pos.y][pos.x]
	return TileType.OBSTACLE

func _get_enemy_type_for_floor() -> String:
	# Simple enemy type selection
	var types = ["slime", "bat", "golem", "scholar"]
	return types[randi() % types.size()]

func _get_enemy_hp_for_type(enemy_type: String) -> int:
	match enemy_type:
		"slime": return 1
		"bat": return 1
		"golem": return 2
		"scholar": return 2
		"boss": return 3
		_: return 1

func _get_difficulty_tier() -> int:
	return 1 + (randi() % 3)  # 1-3

func _get_enemy_taunts(enemy_type: String) -> Array[String]:
	var taunts: Array[String] = []
	match enemy_type:
		"slime":
			taunts = ["You'll slip up on this one!", "Math is slippery!"]
		"bat":
			taunts = ["Can you solve this before I strike?", "You're flying blind!"]
		"golem":
			taunts = ["Your calculations are weak!", "I am impenetrable!"]
		"scholar":
			taunts = ["Let's see your true knowledge!", "Think carefully, student!"]
		_:
			taunts = ["Prepare yourself!", "Can you solve this?"]
	return taunts

func get_enemy_at_position(pos: Vector2i) -> EnemyData:
	for enemy in enemies:
		if enemy.position == pos and not enemy.is_defeated:
			return enemy
	return null

func to_dict() -> Dictionary:
	var grid_data = []
	for row in grid:
		grid_data.append(row.duplicate())
	
	var enemies_data = []
	for enemy in enemies:
		enemies_data.append(enemy.to_dict())
	
	var chests_data = []
	for chest_pos in chest_positions:
		chests_data.append({"x": chest_pos.x, "y": chest_pos.y})
	
	return {
		"grid": grid_data,
		"enemies": enemies_data,
		"chest_positions": chests_data,
		"staircase_position": {"x": staircase_position.x, "y": staircase_position.y},
		"player_spawn": {"x": player_spawn.x, "y": player_spawn.y}
	}

func from_dict(data: Dictionary) -> void:
	# Restore grid
	grid.clear()
	for row_data in data.get("grid", []):
		var row: Array[int] = []
		row.assign(row_data)
		grid.append(row)
	
	# Restore enemies
	enemies.clear()
	for enemy_data in data.get("enemies", []):
		var enemy = EnemyData.new()
		enemy.from_dict(enemy_data)
		enemies.append(enemy)
	
	# Restore chests
	chest_positions.clear()
	for chest_data in data.get("chest_positions", []):
		chest_positions.append(Vector2i(chest_data.get("x", 0), chest_data.get("y", 0)))
	
	# Restore staircase
	var stair_data = data.get("staircase_position", {"x": -1, "y": -1})
	staircase_position = Vector2i(stair_data.get("x", -1), stair_data.get("y", -1))
	
	# Restore player spawn
	var spawn_data = data.get("player_spawn", {"x": 0, "y": 0})
	player_spawn = Vector2i(spawn_data.get("x", 0), spawn_data.get("y", 0))
