extends Node2D
class_name DungeonTile

## Individual dungeon tile

signal clicked(tile_position: Vector2i)

@export var tile_position: Vector2i = Vector2i.ZERO
@export var tile_type: int = 0  # DungeonGenerator.TileType
@export var is_revealed: bool = false

@onready var tile_rect: ColorRect = $TileRect
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
	if not tile_rect:
		return
	
	# Simple color-based visualization for top-down view
	match tile_type:
		0:  # EMPTY
			tile_rect.color = Color(0.8, 0.8, 0.8, 1.0)  # Light gray
		1:  # OBSTACLE
			tile_rect.color = Color(0.3, 0.3, 0.3, 1.0)  # Dark gray
		2:  # ENEMY
			tile_rect.color = Color(0.9, 0.2, 0.2, 1.0)  # Red
		3:  # CHEST
			tile_rect.color = Color(1.0, 0.8, 0.2, 1.0)  # Gold
		4:  # STAIRCASE
			tile_rect.color = Color(0.2, 0.9, 0.2, 1.0)  # Green
		5:  # PLAYER
			tile_rect.color = Color(0.2, 0.5, 1.0, 1.0)  # Blue

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(tile_position)
