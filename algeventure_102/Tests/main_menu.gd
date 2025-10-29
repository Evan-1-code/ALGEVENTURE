extends Node2D

func _ready() -> void:
	if Engine.has_singleton("SceneManager"):
		print("SceneManager found:", SceneManager)
	else:	
		print("❌ SceneManager not loaded")
	
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)
	


func _on_manual_user_pressed() -> void:
	$ManualScreen.open()




@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _on_settings_button_pressed() -> void:
	settings_overlay.open()


func _on_dungeon_arithmetic_pressed() -> void:
	if DungeonManager:
		DungeonManager.load_dungeon("arithmetic")


func _on_dungeon_geometric_pressed() -> void:
	if DungeonManager:
		DungeonManager.load_dungeon("geometric")
