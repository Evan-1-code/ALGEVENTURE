extends Node

var history: Array[String] = []
var current_scene: Node = null


func change_scene(path: String) -> void:
	if current_scene:
		history.append(current_scene.scene_file_path)
	var new_scene = load(path).instantiate()
	get_tree().root.add_child(new_scene)
	if current_scene:
		current_scene.queue_free()
	current_scene = new_scene


func go_back() -> void:
	if history.is_empty():
		return
	var last_scene_path = history.pop_back()
	change_scene(last_scene_path)
