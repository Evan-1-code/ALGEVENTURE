extends Control

func _ready():
	if Engine.has_singleton("SceneManager"):
		print("SceneManager found:", SceneManager)
	else:
		print("❌ SceneManager not loaded")

# Save the current scene's path before switching
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)
	

func _on_arithmetic_pressed() -> void:
	SceneManager.change_scene("res://Scene/LearningPortal.tscn/Artithmethic_levels/arithmetic_levels.tscn")


func _on_geometric_pressed() -> void:
	SceneManager.change_scene("res://Scene/LearningPortal.tscn/Geometric_levels/geometric_levels.tscn")


func _on_button_pressed() -> void:
	SceneManager.change_scene("res://Tests/Main_menu.tscn")

@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _on_settings_button_pressed() -> void:
	settings_overlay.open()
