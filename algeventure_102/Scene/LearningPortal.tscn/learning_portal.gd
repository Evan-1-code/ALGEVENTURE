extends Control


func _on_arithmetic_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/arithmetic_levels.tscn")


func _on_geometric_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/geometric_levels.tscn")
