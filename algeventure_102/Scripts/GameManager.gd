extends Node


var last_door_tag: String = ""

# Maps tags to actual scene paths
var level_map = {
	"town_map": "res://Scene/town_map.tscn",
	"town_map_2": "res://Scene/dungeon.tscn",
}

func load_level_by_tag(tag: String):
	var path = level_map.get(tag, "")
	if path == "":
		print("❌ Unknown level tag:", tag)
		return

	print("Loading level:", path)
	get_tree().change_scene_to_file(path)
