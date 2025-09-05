extends Node

var is_first_load := true # Add this flag

const scene_town_map_1 = preload("res://Scene/Worldmap.tscn/town_map_1.tscn")
const scene_learning_forge = preload("res://Scene/Worldmap.tscn/learning_forge.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"town_map_1":
			scene_to_load = scene_town_map_1
		"learning_forge":
			scene_to_load = scene_learning_forge
			
	if scene_to_load != null:
			spawn_door_tag = destination_tag
			get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
