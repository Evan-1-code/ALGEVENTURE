extends CharacterBody2D

# Player controller for tile-based movement (Godot 4.4)
# - double-click to select / move
# - first double-click highlights a tile border (overlay TileMap)
# - second double-click on a reachable tile (1 tile away, 8 directions) teleports player instantly
# - shows circular markers around player indicating reachable tiles
# - robustly resolves TileMap even if a TileMapLayer or child node was assigned

@export var floor_tilemap_path: NodePath
@export var overlay_tilemap_path: NodePath
@export var border_tile_id: int = 0

@export var marker_color: Color = Color(0.1, 0.7, 0.9, 0.7)
@export var marker_radius_pixels: int = 6
@export var marker_padding: int = 2
@export var double_click_ms: int = 400

# runtime references (resolved in _ready)
var floor_tilemap = null
var overlay_tilemap = null

# runtime state
var _markers = []              # Sprite2D markers
var _selected_tile = null      # currently selected tile (or null)
var _marker_texture = null
var _double_click_timer = null
var _last_click_tile = null

# Helper: walk up parents to find a TileMap node
func _find_tilemap_from(node: Node) -> TileMap:
	var n = node
	while n != null:
		if n is TileMap:
			return n
		n = n.get_parent()
	return null

func _ready() -> void:
	# resolve floor tilemap robustly
	var assigned_floor = get_node_or_null(floor_tilemap_path)
	if assigned_floor == null:
		push_error("player_controller.gd: floor_tilemap_path not assigned or node not found")
		return
	if assigned_floor is TileMap:
		floor_tilemap = assigned_floor
	else:
		floor_tilemap = _find_tilemap_from(assigned_floor)
		if floor_tilemap == null:
			push_error("player_controller.gd: assigned floor node '%s' is not a TileMap and no ancestor TileMap found. Please assign the TileMap node." % [assigned_floor.name])
			return
		else:
			push_warning("player_controller.gd: assigned floor node '%s' is not a TileMap. Using ancestor TileMap '%s'." % [assigned_floor.name, floor_tilemap.name])

	# resolve overlay tilemap robustly
	var assigned_overlay = get_node_or_null(overlay_tilemap_path)
	if assigned_overlay == null:
		push_error("player_controller.gd: overlay_tilemap_path not assigned or node not found")
		return
	if assigned_overlay is TileMap:
		overlay_tilemap = assigned_overlay
	else:
		overlay_tilemap = _find_tilemap_from(assigned_overlay)
		if overlay_tilemap == null:
			push_error("player_controller.gd: assigned overlay node '%s' is not a TileMap and no ancestor TileMap found. Please assign the overlay TileMap node." % [assigned_overlay.name])
			return
		else:
			push_warning("player_controller.gd: assigned overlay node '%s' is not a TileMap. Using ancestor TileMap '%s'." % [assigned_overlay.name, overlay_tilemap.name])

	# keep overlay tilemap aligned with floor settings
	overlay_tilemap.cell_size = floor_tilemap.cell_size
	overlay_tilemap.cell_quadrant_size = floor_tilemap.cell_quadrant_size
	overlay_tilemap.cell_custom_transform = floor_tilemap.cell_custom_transform

	# create marker texture and show initial markers
	_marker_texture = _create_marker_texture(marker_radius_pixels, marker_color)
	show_move_markers()

	# setup timer for double-click detection
	_double_click_timer = Timer.new()
	_double_click_timer.one_shot = true
	_double_click_timer.wait_time = double_click_ms / 1000.0
	add_child(_double_click_timer)
	_double_click_timer.timeout.connect(Callable(self, "_on_double_click_timeout"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = get_global_mouse_position()
		var tile_pos: Vector2 = floor_tile_coords_at_world(world_pos)
		# only act when clicking an existing floor tile
		if not is_floor_tile(tile_pos):
			return
		# if timer running and same cell -> double-click
		if _last_click_tile != null and _last_click_tile == tile_pos and not _double_click_timer.is_stopped():
			handle_click(tile_pos)
			_double_click_timer.stop()
			_last_click_tile = null
		else:
			_last_click_tile = tile_pos
			_double_click_timer.start()

func _on_double_click_timeout() -> void:
	# pending click expired
	_last_click_tile = null

# Utilities
func floor_tile_coords_at_world(world_pos: Vector2) -> Vector2:
	return floor(floor_tilemap.world_to_map(world_pos))

func is_floor_tile(tile_coords: Vector2) -> bool:
	return floor_tilemap.get_cellv(tile_coords) != -1

# Movement logic
func get_reachable_tiles() -> Array:
	var cur = floor_tile_coords_at_world(global_position)
	var tiles = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			tiles.append(Vector2(cur.x + dx, cur.y + dy))
	return tiles

func show_move_markers() -> void:
	_clear_markers()
	var tiles = get_reachable_tiles()
	for t in tiles:
		if not is_floor_tile(t):
			continue
		var top_left = floor_tilemap.map_to_world(t)
		var center = top_left + floor_tilemap.cell_size * 0.5
		var s = Sprite2D.new()
		s.texture = _marker_texture
		# parent to floor_tilemap so it follows map space
		floor_tilemap.add_child(s)
		s.global_position = center
		s.z_index = 100
		_markers.append(s)

func highlight_tile(tile_pos: Vector2) -> void:
	tile_pos = tile_pos.floor()
	# single highlight behavior: clear previous then set new
	clear_highlights()
	overlay_tilemap.set_cellv(tile_pos, border_tile_id)
	_selected_tile = tile_pos

func handle_click(tile_pos: Vector2) -> void:
	tile_pos = tile_pos.floor()
	if _selected_tile == null:
		highlight_tile(tile_pos)
		return
	# if clicked a reachable tile -> move
	for r in get_reachable_tiles():
		if r == tile_pos:
			move_to_tile(tile_pos)
			return
	# otherwise replace selection
	highlight_tile(tile_pos)

func move_to_tile(tile_pos: Vector2) -> void:
	tile_pos = tile_pos.floor()
	var top_left = floor_tilemap.map_to_world(tile_pos)
	global_position = top_left + floor_tilemap.cell_size * 0.5
	clear_highlights()
	show_move_markers()

func clear_highlights() -> void:
	# clear overlay layer
	var used = overlay_tilemap.get_used_cells()
	for c in used:
		overlay_tilemap.set_cellv(c, -1)
	_selected_tile = null
	_clear_markers()

# Marker helpers
func _create_marker_texture(radius: int, color: Color) -> ImageTexture:
	var size = (radius + marker_padding) * 2
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.lock()
	# fill transparent
	for y in range(size):
		for x in range(size):
			img.set_pixel(x, y, Color(0, 0, 0, 0))
	var center = Vector2(size, size) * 0.5
	for y in range(size):
		for x in range(size):
			var p = Vector2(x, y)
			var dist = p.distance_to(center)
			var aa = clamp(1.0 - (dist - radius), 0.0, 1.0)
			if dist <= radius + 1.0:
				var c = color
				c.a *= aa
				img.set_pixel(x, y, c)
	img.unlock()
	var tex = ImageTexture.create_from_image(img)
	return tex

func _clear_markers() -> void:
	for m in _markers:
		if is_instance_valid(m):
			m.queue_free()
	_markers.clear()