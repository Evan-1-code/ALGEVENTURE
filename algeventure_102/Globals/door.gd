extends Area2D

class_name Door

@export var destination_level_tag: String
@export var destination_Door_tag: String
@export var spawn_direction = "up"

@onready var spawn = $Spawn



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Player entered")
		# Defer the scene change to the next idle step
		call_deferred("_change_scene", destination_level_tag, destination_Door_tag)

func _change_scene(level_tag, destination_tag):
	NavigationManager.go_to_level(level_tag, destination_tag)
