extends Control
class_name AchievementPopup

@export var title_label_path: NodePath
@export var desc_label_path: NodePath
@export var icon_texture_rect_path: NodePath
@export var show_seconds: float = 2.0

var _title_label: Label
var _desc_label: Label
var _icon_rect: TextureRect

func _ready() -> void:
	_title_label = get_node_or_null(title_label_path)
	_desc_label = get_node_or_null(desc_label_path)
	_icon_rect = get_node_or_null(icon_texture_rect_path)
	visible = false

	# Connect to the Achievement_Manager autoload safely
	var mgr := get_node_or_null("/root/Achievement_Manager")
	if mgr:
		mgr.achievement_unlocked.connect(_on_achievement_unlocked)

# Avoid shadowing Node.name and prefix unused params
func _on_achievement_unlocked(_id: String, title: String, description: String, _category: String) -> void:
	_show_popup(title, description)

func _show_popup(title_text: String, desc_text: String) -> void:
	if _title_label:
		_title_label.text = title_text
	if _desc_label:
		_desc_label.text = desc_text
	visible = true
	modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(show_seconds).timeout
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	visible = false
