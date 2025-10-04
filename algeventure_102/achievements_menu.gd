extends Control
class_name AchievementsMenu

@onready var list_container: VBoxContainer = %ListContainer

func _ready() -> void:
	# Make sure the list stretches horizontally so centered labels have room
	if list_container:
		list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refresh()

func _refresh() -> void:
	if not list_container:
		return
	_clear_list()

	var mgr := _mgr()
	if mgr == null:
		var warn := Label.new()
		warn.text = "Achievement_Manager not found (is Autoload set up?)."
		warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		warn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		list_container.add_child(warn)
		return

	var all: Dictionary = mgr.call("get_all_achievements")
	var unlocked: Dictionary = mgr.call("get_unlocked_data")

	for id in all.keys():
		var meta := (all[id] as Dictionary)
		var is_unlocked: bool = unlocked.has(id)
		var title := String(meta.get("name", ""))
		var category := String(meta.get("category", ""))
		var _desc := String(meta.get("description", ""))

		# Panel row that fills width
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_constant_override("margin_left", 8)
		panel.add_theme_constant_override("margin_right", 8)
		panel.add_theme_constant_override("margin_top", 6)
		panel.add_theme_constant_override("margin_bottom", 6)

		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_child(vb)

		# Title line centered
		var title_lbl := Label.new()
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.text = "%s — %s" % [title, category]
		vb.add_child(title_lbl)

		# Status or hint, centered
		if is_unlocked:
			var status := Label.new()
			status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			status.text = "Unlocked"
			status.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
			vb.add_child(status)
		else:
			var hint := Label.new()
			hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hint.text = _hint_for(id)
			hint.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
			hint.add_theme_font_size_override("font_size", 12)
			vb.add_child(hint)

		list_container.add_child(panel)

		# Small vertical spacer between rows
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 6)
		list_container.add_child(spacer)

func _clear_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

func _hint_for(id: String) -> String:
	match id:
		"first_steps":
			return "??? – Complete more Arithmetic or Geometric levels."
		"arithmetic_adept":
			return "??? – Reach the midpoint of Arithmetic."
		"arithmetic_master":
			return "??? – Clear all Arithmetic levels."
		"geometric_adept":
			return "??? – Reach the midpoint of Geometric."
		"geometric_master":
			return "??? – Clear all Geometric levels."
		"adaptive_explorer":
			return "??? – Finish many problems in Adaptive mode in one go."
		"difficulty_tamer":
			return "??? – Face the hardest problems and prevail."
		"flawless_streak":
			return "??? – Stay perfect for a short streak."
		"perfect_pair":
			return "??? – Master both paths in harmony."
		_:
			return "???"

# Helper to get the renamed autoload
func _mgr() -> Node:
	return get_node_or_null("/root/Achievement_Manager")


@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _on_settings_button_pressed() -> void:
	settings_overlay.open()
