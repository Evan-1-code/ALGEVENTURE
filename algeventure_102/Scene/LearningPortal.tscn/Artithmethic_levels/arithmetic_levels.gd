extends Control

@onready var al1_button: Button = $HBoxContainer/Button
@onready var al2_button: Button = $HBoxContainer/Button2
@onready var al3_button: Button = $HBoxContainer/Button3
@onready var al4_button: Button = $HBoxContainer/Button4
@onready var al5_button: Button = $HBoxContainer/Button5
@onready var al6_button: Button = $HBoxContainer/Button6
@onready var al7_button: Button = $HBoxContainer/Button7
@onready var al8_button: Button = $HBoxContainer/Button8
@onready var al9_button: Button = $HBoxContainer/Button9
@onready var al10_button: Button = $HBoxContainer/Button10
@onready var al11_button: Button = $HBoxContainer/Button11
@onready var al12_button: Button = $HBoxContainer/Button12
@onready var al13_button: Button = $HBoxContainer/Button13
@onready var al14_button: Button = $HBoxContainer/Button14

func _ready():
	al1_button.disabled = false
	al2_button.disabled = not ProgressManager.progress["al_1"]
	al3_button.disabled = not ProgressManager.progress["al_2"]
	al4_button.disabled = not ProgressManager.progress["al_3"]
	al5_button.disabled = not ProgressManager.progress["al_4"]
	al6_button.disabled = not ProgressManager.progress["al_5"]
	al7_button.disabled = not ProgressManager.progress["al_6"]
	al8_button.disabled = not ProgressManager.progress["al_7"]
	al9_button.disabled = not ProgressManager.progress["al_8"]
	al10_button.disabled = not ProgressManager.progress["al_9"]
	al11_button.disabled = not ProgressManager.progress["al_10"]
	al12_button.disabled = not ProgressManager.progress["al_11"]
	al13_button.disabled = not ProgressManager.progress["al_12"]
	al14_button.disabled = not ProgressManager.progress["al_13"]

# Save the current scene's path before switching
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)
	print("al1:", !al1_button.disabled)
	print("al2:", !al2_button.disabled)
	print("al3:", !al3_button.disabled)
	print("al4:", !al4_button.disabled)
	

@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _on_settings_button_pressed() -> void:
	settings_overlay.open()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_1.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_2.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_3.tscn")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_4.tscn")


func _on_button_5_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_5.tscn")


func _on_button_6_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_6.tscn")


func _on_button_7_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_7.tscn")


func _on_button_8_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_8.tscn")


func _on_button_9_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_9.tscn")


func _on_button_10_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_10.tscn")


func _on_button_11_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_11.tscn")


func _on_button_12_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_12.tscn")


func _on_button_13_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_13.tscn")


func _on_button_14_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/al_14.tscn")
