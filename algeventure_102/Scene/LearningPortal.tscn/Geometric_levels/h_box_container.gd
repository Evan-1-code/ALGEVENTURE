extends HBoxContainer

@export var min_sep := 0.2      # Minimum space between buttons
@export var max_sep := 6.0     # Maximum space when screen is wide
@export var ref_width := 960.0  # Reference viewport width

func _ready():
	_update_spacing()
	get_viewport().size_changed.connect(_update_spacing)

func _update_spacing():
	var width = get_viewport_rect().size.x
	var t = clamp(width / ref_width, 0.1, 0.2)
	var new_sep = lerp(min_sep, max_sep, (t - 0.2)/ 6.0)
	add_theme_constant_override("separation", int(new_sep))
