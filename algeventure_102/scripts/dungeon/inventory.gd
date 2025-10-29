extends Node
class_name Inventory

## Manages player inventory and item usage

signal item_added(item_name: String, count: int)
signal item_used(item_name: String)
signal item_removed(item_name: String, count: int)

var player_state: PlayerState

func _init(state: PlayerState = null) -> void:
	if state:
		player_state = state
	else:
		player_state = PlayerState.new()

func add_item(item_name: String, count: int = 1) -> void:
	player_state.add_item(item_name, count)
	item_added.emit(item_name, count)

func use_item(item_name: String) -> bool:
	var success = false
	
	match item_name:
		"potion":
			success = player_state.use_potion()
		"scroll":
			success = player_state.use_scroll()
		"boots":
			if player_state.inventory.get("boots", 0) > 0:
				player_state.inventory["boots"] -= 1
				success = true
		"torch":
			if player_state.inventory.get("torch", 0) > 0:
				player_state.inventory["torch"] -= 1
				success = true
		"armor":
			# Armor is equipped, not used
			success = false
	
	if success:
		item_used.emit(item_name)
	
	return success

func has_item(item_name: String, min_count: int = 1) -> bool:
	var item_value = player_state.inventory.get(item_name, 0)
	
	if typeof(item_value) == TYPE_BOOL:
		return item_value
	else:
		return item_value >= min_count

func get_item_count(item_name: String) -> int:
	var item_value = player_state.inventory.get(item_name, 0)
	
	if typeof(item_value) == TYPE_BOOL:
		return 1 if item_value else 0
	else:
		return item_value

func equip_armor() -> void:
	player_state.inventory["armor"] = true

func has_armor() -> bool:
	return player_state.inventory.get("armor", false)

func generate_chest_loot() -> Array[Dictionary]:
	# Generate random loot for chest
	var loot: Array[Dictionary] = []
	var roll = randf()
	
	if roll < 0.5:
		# Common: potion or small XP
		loot.append({"type": "potion", "count": 1})
	elif roll < 0.75:
		# Uncommon: scroll or boots
		if randf() < 0.5:
			loot.append({"type": "scroll", "count": 1})
		else:
			loot.append({"type": "boots", "count": 1})
	else:
		# Rare: armor or torch
		if randf() < 0.3:
			loot.append({"type": "armor", "count": 1})
		else:
			loot.append({"type": "torch", "count": 1})
	
	# Sometimes add extra item
	if randf() < 0.3:
		loot.append({"type": "potion", "count": 1})
	
	return loot

func apply_loot(loot: Array[Dictionary]) -> void:
	for item in loot:
		var item_type = item.get("type", "")
		var count = item.get("count", 1)
		
		if item_type == "armor":
			equip_armor()
		else:
			add_item(item_type, count)
