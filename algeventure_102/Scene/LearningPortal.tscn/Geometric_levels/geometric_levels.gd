extends Control

# --- BUTTON REFERENCES ---
@onready var buttons := [
	$ScrollContainer/HBoxContainer/Button,
	$ScrollContainer/HBoxContainer/Button2,
	$ScrollContainer/HBoxContainer/Button3,
	$ScrollContainer/HBoxContainer/Button4,
	$ScrollContainer/HBoxContainer/Button5,
	$ScrollContainer/HBoxContainer/Button6,
	$ScrollContainer/HBoxContainer/Button7,
	$ScrollContainer/HBoxContainer/Button8,
	$ScrollContainer/HBoxContainer/Button9,
	$ScrollContainer/HBoxContainer/Button10,
	$ScrollContainer/HBoxContainer/Button11,
	$ScrollContainer/HBoxContainer/Button12,
	$ScrollContainer/HBoxContainer/Button13,
	$ScrollContainer/HBoxContainer/Button14
]

@onready var settings_overlay := $option_menu
@onready var back_button := $BackButton # add this node in your scene
@onready var main_menu_button := $MainMenuButton # add this node in your scene

# --- VARIABLES ---
var total_levels := 14
var save_path := "user://save_data.cfg"
var unlocked_level := 1


# --- READY ---
func _ready() -> void:
	if get_tree().current_scene:
		get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)

	load_progress()
	update_buttons()

	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_level_pressed.bind(i + 1))

	if is_instance_valid(back_button):
		back_button.pressed.connect(_on_back_button_pressed)

	if is_instance_valid(main_menu_button):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)

	# Save automatically when quitting the app
	get_tree().root.tree_exiting.connect(_on_tree_exiting)


# --- SETTINGS MENU ---
func _on_settings_button_pressed() -> void:
	if settings_overlay and settings_overlay.has_method("open"):
		settings_overlay.open()


# --- LEVEL BUTTON HANDLER ---
func _on_level_pressed(level: int) -> void:
	if level <= unlocked_level:
		var level_path = "res://Scene/LearningPortal.tscn/Geometric_levels/gl_%d.tscn" % level
		if ResourceLoader.exists(level_path):
			get_tree().change_scene_to_file(level_path)
		else:
			push_error("Scene not found: " + level_path)
	else:
		print("⚠️ Level %d is locked!" % level)


# --- SAVE / LOAD SYSTEM ---
func load_progress() -> void:
	var config := ConfigFile.new()
	var err := config.load(save_path)
	if err == OK:
		unlocked_level = config.get_value("Progress", "UnlockedLevel", 1)
	else:
		unlocked_level = 1

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("Progress", "UnlockedLevel", unlocked_level)
	config.save(save_path)
	print("💾 Progress saved (Unlocked up to level %d)" % unlocked_level)


# --- UNLOCK NEXT LEVEL ---
func unlock_next_level(current_level: int) -> void:
	if current_level >= unlocked_level and current_level < total_levels:
		unlocked_level = current_level + 1
		save_progress()
		update_buttons()


# --- UPDATE BUTTON STATES ---
func update_buttons() -> void:
	for i in range(buttons.size()):
		if i + 1 <= unlocked_level:
			buttons[i].disabled = false
			buttons[i].modulate = Color(1, 1, 1)
		else:
			buttons[i].disabled = true
			buttons[i].modulate = Color(0.5, 0.5, 0.5)


# --- AUTO SAVE ON EXIT ---
func _on_tree_exiting() -> void:
	save_progress()


# --- BACK BUTTON HANDLER ---
func _on_back_button_pressed() -> void:
	save_progress()
	print("⬅️ Back button pressed, progress saved")
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/level_select.tscn")


# --- MAIN MENU BUTTON HANDLER ---
func _on_main_menu_button_pressed() -> void:
	save_progress()
	print("🏠 Main Menu button pressed, progress saved")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
