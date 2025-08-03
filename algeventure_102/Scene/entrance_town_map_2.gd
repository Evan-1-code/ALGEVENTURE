extends Area2D

@export var destination_scene: PackedScene
@export var destination_spawn_name: String = "spawn_point"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.set_meta("spawn_tag", "town_entrance_2")  # must match node name in next scene
		get_tree().change_scene_to_file("res://Scene/town_map_2.tscn")
