extends Node2D

func _ready() -> void:
	if Engine.has_singleton("SceneManager"):
		print("SceneManager found:", SceneManager)
	else:	
		print("❌ SceneManager not loaded")
	
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)
	


func _on_manual_user_pressed() -> void:
	$ManualScreen.open()
