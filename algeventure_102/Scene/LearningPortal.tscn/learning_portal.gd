extends Control

func _ready():
	if Engine.has_singleton("SceneManager"):
		print("SceneManager found:", SceneManager)
	else:
		print("❌ SceneManager not loaded")

func _on_arithmetic_pressed() -> void:
	SceneManager.change_scene("res://Scene/LearningPortal.tscn/Artithmethic_levels/arithmetic_levels.tscn")


func _on_geometric_pressed() -> void:
	SceneManager.change_scene("res://Scene/LearningPortal.tscn/Geometric_levels/geometric_levels.tscn")
