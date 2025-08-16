extends Node

signal spawn_player

func _ready():
	if NavigationManager.spawn_door_tag != null:
		emit_signal("spawn_player", NavigationManager.spawn_door_tag)

func _spawn_player_at_door(destination_tag: String):
	var door_name = "Door_" + destination_tag
	var door = get_node_or_null(door_name)
	
	if door:
		var player = get_node("res://Animation/Player/player(test).tscn") # replace with your actual Player path
		if player:
			player.global_position = door.spawn.global_position
			# Optional: set direction if your player script supports it
			# player.facing_direction = door.spawn_direction
		else:
			push_warning("Player node not found in this level!")
			push_warning("Door with tag " + destination_tag + " not found in this level!")
  
 
