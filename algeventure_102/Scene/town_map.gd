extends Node2D


func _ready():
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.destination_door_tag == GameManager.last_door_tag:
			print("Spawning player at:", door.name)
			var player = get_node("Player")
			player.global_position = door.spawn.global_position
			break


func _on_entrance_town_map_2_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scene/town_map_2.tscn")
