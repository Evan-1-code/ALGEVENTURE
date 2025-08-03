extends CharacterBody2D


@export var move_speed: float = 100.0
var last_direction = "down"

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()

	# Play walk or idle animations
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"

		$AnimatedSprite2D.play("walk_" + last_direction)
	else:
		$AnimatedSprite2D.play("idle_" + last_direction)
