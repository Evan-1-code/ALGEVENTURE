extends Node2D


func _ready():
	var player = get_node_or_null("Player")
	
	if player == null:
		print("❌ Player not found in this scene!")
	return
	
	if player.has_meta("spawn_tag"):
		var tag = player.get_meta("spawn_tag")
		var spawn_point = get_node_or_null(tag)
		if spawn_point:
			player.global_position = spawn_point.global_position
			print("✅ Moved player to:", tag)
	else:
			print("❌ Spawn point not found:", "tag")


func _on_door_to_town_map_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scene/town_map.tscn")
