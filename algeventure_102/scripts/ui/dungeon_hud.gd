extends CanvasLayer

## Dungeon HUD - displays player stats, floor info, and controls

@onready var hearts_label = $MarginContainer/VBoxContainer/TopBar/HeartsLabel
@onready var moves_label = $MarginContainer/VBoxContainer/TopBar/MovesLabel
@onready var floor_label = $MarginContainer/VBoxContainer/TopBar/FloorLabel
@onready var kills_label = $MarginContainer/VBoxContainer/TopBar/KillsLabel
@onready var inventory_container = $MarginContainer/VBoxContainer/InventoryBar

func _ready() -> void:
	pass

func update_display(player_state: PlayerState, config: DungeonConfig) -> void:
	if hearts_label:
		hearts_label.text = "Hearts: %.1f/%.1f" % [player_state.hearts, player_state.max_hearts]
	
	if moves_label:
		moves_label.text = "Moves: %d" % player_state.moves_left
	
	if floor_label:
		floor_label.text = "Floor: %d/%d" % [player_state.current_floor + 1, config.max_floors]
	
	if kills_label:
		var required = config.get_required_kills()
		kills_label.text = "Kills: %d/%d" % [player_state.kills_this_floor, required]
	
	_update_inventory(player_state)

func _update_inventory(player_state: PlayerState) -> void:
	if not inventory_container:
		return
	
	# Clear existing inventory display
	for child in inventory_container.get_children():
		child.queue_free()
	
	# Display inventory items
	var inv = player_state.inventory
	var items_text = ""
	
	if inv.get("potion", 0) > 0:
		items_text += "Potions: %d " % inv["potion"]
	if inv.get("scroll", 0) > 0:
		items_text += "Scrolls: %d " % inv["scroll"]
	if inv.get("boots", 0) > 0:
		items_text += "Boots: %d " % inv["boots"]
	if inv.get("torch", 0) > 0:
		items_text += "Torches: %d " % inv["torch"]
	if inv.get("armor", false):
		items_text += "Armor: Equipped "
	
	var inv_label = Label.new()
	inv_label.text = items_text if items_text != "" else "No items"
	inventory_container.add_child(inv_label)
