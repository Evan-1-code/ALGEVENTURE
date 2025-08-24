extends Area2D
class_name Door
var active = false
@export var destination_level_tag: String
@export var destination_door_tag: String
@export var door_tag: String
@export var spawn_direction = "up"

@onready var spawn = $Spawn

func _ready():
	add_to_group("doors")
	if door_tag != "":
		add_to_group(door_tag)
		active = false
		await get_tree().create_timer(0.3).timeout
		active = true

func _on_body_entered(body: Node2D) -> void:
	if not active:
		return
	if body is Player:
		print("Player entered door: ", destination_door_tag)
		call_deferred("_change_scene", destination_level_tag, destination_door_tag)

func _change_scene(level_tag, destination_tag):
		NavigationManager.go_to_level(level_tag, destination_tag)
