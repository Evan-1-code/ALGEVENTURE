extends Area2D

@export var target_scene: String = ""
@onready var highlight = $ColorRect

func _ready():
	highlight.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered():
	highlight.visible = true

func _on_mouse_exited():
	highlight.visible = false

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
