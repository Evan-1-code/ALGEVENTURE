extends Control

@onready var scroll_container: ScrollContainer = $HBoxContainer/MainPanel/ScrollContainer
@onready var content_container: VBoxContainer = $HBoxContainer/MainPanel/ScrollContainer/ContentContainer
@onready var nav_container: VBoxContainer = $HBoxContainer/NavPanel/NavContainer

@export var manual_path: String = "res://data/manual.json"
@export var start_hidden: bool = true
@export var dim_background: bool = true
@export_range(0.0, 1.0, 0.05) var dim_alpha: float = 0.6

var last_modified_time: int = 0
var section_positions: Dictionary = {} # section_id -> y position

const CONTENT_MAX_WIDTH: int = 720
const USE_RICHTEXT: bool = true

func _ready() -> void:
	_setup_runtime_center_wrapper()
	_prepare_overlay_behavior()
	_prepare_nav_container_for_bottom_button()
	load_manual()

	var timer: Timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

	if start_hidden:
		hide()

func _prepare_overlay_behavior() -> void:
	# Fill screen and block input to what's underneath when visible
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100

	# Optional dim background if there's a ColorRect
	if has_node("ColorRect"):
		var c: ColorRect = $ColorRect
		c.set_anchors_preset(Control.PRESET_FULL_RECT)
		var a: float = (dim_alpha if dim_background else 0.0)
		c.color = Color(0, 0, 0, a)
		c.mouse_filter = Control.MOUSE_FILTER_STOP
		c.visible = not start_hidden

func _prepare_nav_container_for_bottom_button() -> void:
	nav_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _setup_runtime_center_wrapper() -> void:
	# Center ContentContainer without editing your scene
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	if scroll_container.get_node_or_null("ContentWrapper") != null:
		return
	if content_container.get_parent() != scroll_container:
		return

	var wrapper: HBoxContainer = HBoxContainer.new()
	wrapper.name = "ContentWrapper"
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL

	scroll_container.remove_child(content_container)
	scroll_container.add_child(wrapper)

	var left_spacer: Control = Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_spacer.size_flags_vertical = Control.SIZE_FILL

	content_container.size_flags_horizontal = 0 # don't expand; fixed column width
	content_container.custom_minimum_size.x = CONTENT_MAX_WIDTH

	var right_spacer: Control = Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_spacer.size_flags_vertical = Control.SIZE_FILL

	wrapper.add_child(left_spacer)
	wrapper.add_child(content_container)
	wrapper.add_child(right_spacer)

func _on_timer_timeout() -> void:
	check_file_changes()

func check_file_changes() -> void:
	var f: FileAccess = FileAccess.open(manual_path, FileAccess.READ)
	if f != null:
		var modified_time: int = FileAccess.get_modified_time(manual_path)
		if modified_time != last_modified_time:
			last_modified_time = modified_time
			load_manual()

func load_manual() -> void:
	# Clear dynamic content
	for child in content_container.get_children():
		(child as Node).queue_free()
	for child in nav_container.get_children():
		(child as Node).queue_free()
	section_positions.clear()

	# Load JSON
	var f: FileAccess = FileAccess.open(manual_path, FileAccess.READ)
	if f == null:
		printerr("Failed to open manual.json at ", manual_path)
		return
	var json_text: String = f.get_as_text()
	last_modified_time = FileAccess.get_modified_time(manual_path)

	var json: JSON = JSON.new()
	var err: int = json.parse(json_text)
	if err != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return
	var data: Dictionary = json.get_data() as Dictionary
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Invalid JSON root (expected Dictionary).")
		return

	# Title
	var title_label: Label = Label.new()
	title_label.text = data.get("title", "SeQuest Manual")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.custom_minimum_size.y = 56
	content_container.add_child(title_label)

	# Sections
	var sections: Array = data.get("sections", []) as Array
	if sections.is_empty():
		push_warning("manual.json has no 'sections' or it's empty.")
	for section_data in sections:
		var section: Dictionary = section_data as Dictionary
		var sid: String = str(section.get("id", ""))
		if sid.is_empty():
			continue
		var stitle: String = str(section.get("title", sid.capitalize()))
		var scontent: Array = section.get("content", []) as Array

		# Header
		var section_header: Label = Label.new()
		section_header.text = stitle
		section_header.name = "Header_" + sid
		section_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		section_header.add_theme_font_size_override("font_size", 20)
		section_header.custom_minimum_size.y = 40
		content_container.add_child(section_header)

		# Register position after layout
		call_deferred("_register_section_position", sid)

		# Paragraphs
		for paragraph in scontent:
			if USE_RICHTEXT:
				var rtl: RichTextLabel = RichTextLabel.new()
				rtl.bbcode_enabled = true
				rtl.fit_content = true
				rtl.autowrap_mode = TextServer.AUTOWRAP_WORD
				rtl.scroll_active = false
				rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				rtl.add_theme_color_override("default_color", Color(1, 1, 1))
				rtl.text = str(paragraph)
				content_container.add_child(rtl)
			else:
				var p: Label = Label.new()
				p.autowrap_mode = TextServer.AUTOWRAP_WORD
				p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				p.add_theme_color_override("font_color", Color(1, 1, 1))
				p.text = str(paragraph)
				content_container.add_child(p)

			var spacer: Control = Control.new()
			spacer.custom_minimum_size.y = 10
			content_container.add_child(spacer)

		var section_spacer: Control = Control.new()
		section_spacer.custom_minimum_size.y = 30
		content_container.add_child(section_spacer)

		# Nav button for this section
		var nav_button: Button = Button.new()
		nav_button.text = stitle
		nav_button.custom_minimum_size.y = 36
		nav_button.pressed.connect(_on_nav_button_pressed.bind(sid))
		nav_container.add_child(nav_button)

	# Add the bottom Back button
	_add_back_button()

	# Debug
	print("Manual loaded: ", content_container.get_child_count(), " content children; ",
		nav_container.get_child_count(), " nav entries (including Back).")

func _add_back_button() -> void:
	# Separator
	var sep: HSeparator = HSeparator.new()
	nav_container.add_child(sep)

	# Flexible spacer to push Back button to bottom
	var bottom_spacer: Control = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND
	nav_container.add_child(bottom_spacer)

	# Back button
	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size.y = 40
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button.pressed.connect(_on_back_pressed)
	nav_container.add_child(back_button)

func _register_section_position(section_id: String) -> void:
	await get_tree().process_frame
	var header_node: Control = content_container.get_node_or_null("Header_" + section_id) as Control
	if header_node != null:
		section_positions[section_id] = header_node.position.y
	else:
		printerr("Could not find header for section: ", section_id)

func _on_nav_button_pressed(section_id: String) -> void:
	var header_node: Control = content_container.get_node_or_null("Header_" + section_id) as Control
	if header_node == null:
		return
	var target: float = header_node.position.y
	if section_positions.has(section_id):
		target = float(section_positions[section_id])

	var tween: Tween = create_tween()
	tween.tween_property(scroll_container, "scroll_vertical", target, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_back_pressed() -> void:
	close()

# Public API for overlay behavior
func open(section_id: String = "") -> void:
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	if has_node("ColorRect"):
		var c: ColorRect = $ColorRect
		var a: float = (dim_alpha if dim_background else 0.0)
		c.color = Color(0, 0, 0, a)
		c.visible = true
	if section_id != "":
		await get_tree().process_frame
		_on_nav_button_pressed(section_id)

func close() -> void:
	hide()
	if has_node("ColorRect"):
		var c: ColorRect = $ColorRect
		c.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
