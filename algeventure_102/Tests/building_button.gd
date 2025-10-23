extends Button

@export var target_scene: String = ""

func _ready():
	# Connect signals if not done in the editor
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	self.connect("pressed", Callable(self, "_on_pressed"))

func _on_mouse_entered():
	modulate = Color(0.7, 0.7, 0.7) # Slightly darken the button

func _on_mouse_exited():
	modulate = Color(1, 1, 1) # Restore normal color

func _on_pressed():
	print("button pressed")
	if target_scene != "":
		get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)
		print("previous_scene_path")
		get_tree().change_scene_to_file(target_scene)
