extends Node

@export var PlayerScene = load("res://Animation/Player/player(test).tscn") as PackedScene# Drag Player.tscn here

var player: Node2D 
var player_inside = false

func _ready():
	if NavigationManager.is_first_load and get_name() == "town_map_1":
		NavigationManager.is_first_load = false
		call_deferred("_spawn_player_center")
	else:
		var door_tag = NavigationManager.spawn_door_tag if NavigationManager.spawn_door_tag != null else "Door_N"
		call_deferred("_spawn_player_at_door", door_tag)

func _spawn_player_center():
	if player:
		player.queue_free()
	player = PlayerScene.instantiate()
	add_child(player)
	var spawn_point = $PlayerSpawn.global_position
	player.global_position = spawn_point# spawn in center of viewport or at a specific position
 # Center of screen
	# OR: player.global_position = Vector2(320, 180) (for fixed position)

func _spawn_player_at_door(door_group: String) -> void:
	if player == null:
		player = PlayerScene.instantiate()
		add_child(player)
	
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.door_tag == door_group:
			player.global_position = door.global_position
			return
	
	push_warning("Door with tag %s not found in this level!" % door_group)

@export var target_scene: String = "res://Scene/LearningPortal.tscn/learning_portal.tscn"
