extends Node2D

@onready var sprite := $SpriteA

const IMAGE_WIDTH := 793
const SCREEN_WIDTH := 1152
var speed := 300

func _ready():
	sprite.position = Vector2(0, 0)

func _process(delta):
	sprite.position.x -= speed * delta

	# When it's fully off the left edge, reset to the right edge
	if sprite.position.x <= -IMAGE_WIDTH:
		sprite.position.x = SCREEN_WIDTH
