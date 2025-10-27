extends Node2D
class_name Tile

## Individual dungeon tile

signal clicked(tile_position: Vector2i)

@export var tile_position: Vector2i = Vector2i.ZERO
@export var tile_type: int = 0  # DungeonGenerator.TileType
@export var is_revealed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var fog_overlay: ColorRect = $FogOverlay

func _ready() -> void:
	update_visuals()

func set_tile_data(pos: Vector2i, type: int) -> void:
	tile_position = pos
	tile_type = type
	update_visuals()

func reveal() -> void:
	is_revealed = true
	if fog_overlay:
		fog_overlay.visible = false

func hide_in_fog() -> void:
	is_revealed = false
	if fog_overlay:
		fog_overlay.visible = true

func update_visuals() -> void:
	if not sprite:
		return
	
	# Simple color-based visualization
	match tile_type:
		0:  # EMPTY
			sprite.modulate = Color.WHITE
		1:  # OBSTACLE
			sprite.modulate = Color.DARK_GRAY
		2:  # ENEMY
			sprite.modulate = Color.RED
		3:  # CHEST
			sprite.modulate = Color.GOLD
		4:  # STAIRCASE
			sprite.modulate = Color.GREEN
		5:  # PLAYER
			sprite.modulate = Color.BLUE

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(tile_position)
