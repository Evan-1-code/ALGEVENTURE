extends Area2D

@export var target_scene: String = "res://Scene/LearningPortal.tscn/learning_portal.tscn"
var player_inside := false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false


func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file( "res://Scene/LearningPortal.tscn/learning_portal.tscn")
	 
