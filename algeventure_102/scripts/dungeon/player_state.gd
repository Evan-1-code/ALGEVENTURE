extends Node
class_name PlayerState

## Player state data structure

var pos: Vector2i = Vector2i.ZERO
var hearts: float = 3.0
var max_hearts: float = 3.0
var moves_left: int = 5
var inventory: Dictionary = {
	"potion": 0,
	"scroll": 0,
	"armor": false,
	"boots": 0,
	"torch": 0
}
var xp: int = 0
var level: int = 1
var current_floor: int = 0
var dungeon_type: String = "arithmetic"
var kills_this_floor: int = 0

func reset_moves(base_moves: int) -> void:
	moves_left = base_moves

func use_move() -> bool:
	if moves_left > 0:
		moves_left -= 1
		return true
	return false

func add_xp(amount: int) -> void:
	xp += amount
	check_level_up()

func check_level_up() -> void:
	var new_level = 1 + xp / 100
	if new_level > level:
		level = new_level
		# Every 2 levels, add 1 max heart
		if level % 2 == 0:
			max_hearts += 1.0
			hearts = max_hearts

func take_damage(amount: float) -> void:
	hearts = max(0.0, hearts - amount)

func heal(amount: float) -> void:
	hearts = min(max_hearts, hearts + amount)

func use_potion() -> bool:
	if inventory["potion"] > 0:
		inventory["potion"] -= 1
		heal(1.0)
		return true
	return false

func use_scroll() -> bool:
	if inventory["scroll"] > 0:
		inventory["scroll"] -= 1
		return true
	return false

func add_item(item_name: String, count: int = 1) -> void:
	if item_name in inventory:
		if typeof(inventory[item_name]) == TYPE_BOOL:
			inventory[item_name] = true
		else:
			inventory[item_name] += count

func is_alive() -> bool:
	return hearts > 0.0

func to_dict() -> Dictionary:
	return {
		"pos": {"x": pos.x, "y": pos.y},
		"hearts": hearts,
		"max_hearts": max_hearts,
		"moves_left": moves_left,
		"inventory": inventory.duplicate(),
		"xp": xp,
		"level": level,
		"current_floor": current_floor,
		"dungeon_type": dungeon_type,
		"kills_this_floor": kills_this_floor
	}

func from_dict(data: Dictionary) -> void:
	pos = Vector2i(data.get("pos", {}).get("x", 0), data.get("pos", {}).get("y", 0))
	hearts = data.get("hearts", 3.0)
	max_hearts = data.get("max_hearts", 3.0)
	moves_left = data.get("moves_left", 5)
	inventory = data.get("inventory", {
		"potion": 0,
		"scroll": 0,
		"armor": false,
		"boots": 0,
		"torch": 0
	}).duplicate()
	xp = data.get("xp", 0)
	level = data.get("level", 1)
	current_floor = data.get("current_floor", 0)
	dungeon_type = data.get("dungeon_type", "arithmetic")
	kills_this_floor = data.get("kills_this_floor", 0)
