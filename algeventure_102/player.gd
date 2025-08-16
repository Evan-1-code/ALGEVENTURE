extends CharacterBody2D

class_name Player

@export var move_speed : float = 100

func _physics_process(_delta):
	
	var input_direction =Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	
	velocity=input_direction * move_speed
	
	
	move_and_slide()

func _ready():
	var level = get_tree().get_current_scene()  # or adjust path if needed
	level.connect("spawn_player", Callable(self, "_on_spawn"))
 
	

# This is the function you asked about
func _on_spawn(door_tag):
	var door = get_node("NODE/Door_" + door_tag)
	if door:
		global_position = door.spawn.global_position
		print("Player spawned at door: ", door_tag)
	
