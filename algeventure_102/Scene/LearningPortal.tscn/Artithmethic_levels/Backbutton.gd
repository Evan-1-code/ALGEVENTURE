extends Button

func _ready():
	text = "Back"
	pressed.connect(_on_Back_pressed)

func _on_Back_pressed():
	var tree = get_tree()
	if tree.has_meta("previous_scene_path"):
		var prev_scene = tree.get_meta("previous_scene_path")
		tree.change_scene_to_file(prev_scene)
	else:
		print("No previous_scene_path meta found!")# Fallback to quit or handle no previous scene stored
		tree.quit()
