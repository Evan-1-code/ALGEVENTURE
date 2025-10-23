extends Control

const NUM_GL_LEVELS := 14
var gl_buttons: Array = []

@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _ready():
	ProgressManager.load_progress()
	gl_buttons = [
		$HBoxContainer/Button,
		$HBoxContainer/Button2,
		$HBoxContainer/Button3,
		$HBoxContainer/Button4,
		$HBoxContainer/Button5,
		$HBoxContainer/Button6,
		$HBoxContainer/Button7,
		$HBoxContainer/Button8,
		$HBoxContainer/Button9,
		$HBoxContainer/Button10,
		$HBoxContainer/Button11,
		$HBoxContainer/Button12,
		$HBoxContainer/Button13,
		$HBoxContainer/Button14
	]
	for i in range(NUM_GL_LEVELS):
		if i == 0:
			gl_buttons[i].disabled = false
		else:
			var prev_key = "gl_" + str(i)
			gl_buttons[i].disabled = not ProgressManager.progress.get(prev_key, false)
	for i in range(NUM_GL_LEVELS):
		print("gl", i + 1, ":", !gl_buttons[i].disabled)
	for i in range(NUM_GL_LEVELS):
		gl_buttons[i].pressed.connect(_on_gl_button_pressed.bind(i))
	for btn in gl_buttons:
		if !btn.disabled:
			btn.grab_focus()
			break
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)

func _on_settings_button_pressed() -> void:
	settings_overlay.open()

func _on_gl_button_pressed(idx: int) -> void:
	ProgressManager.current_level_index = idx
	ProgressManager.current_level_key = "gl_" + str(idx + 1)
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_%d.tscn" % (idx + 1))
