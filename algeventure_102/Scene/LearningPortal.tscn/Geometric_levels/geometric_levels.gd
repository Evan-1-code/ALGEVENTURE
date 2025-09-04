extends Control

@onready var gl2_button: Button = $HBoxContainer/Button2
@onready var gl3_button: Button = $HBoxContainer/Button3
@onready var gl4_button: Button = $HBoxContainer/Button4
@onready var gl5_button: Button = $HBoxContainer/Button5
@onready var gl6_button: Button = $HBoxContainer/Button6
@onready var gl7_button: Button = $HBoxContainer/Button7

func _ready():
	gl2_button.disabled = not ProgressManager.progress["gl_1"]
	gl3_button.disabled = not ProgressManager.progress["gl_2"]
	gl4_button.disabled = not ProgressManager.progress["gl_3"]
	gl5_button.disabled = not ProgressManager.progress["gl_4"]
	gl6_button.disabled = not ProgressManager.progress["gl_5"]
	gl7_button.disabled = not ProgressManager.progress["gl_6"]

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_1.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_2.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_3.tscn")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_4.tscn")


func _on_button_5_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_5.tscn")


func _on_button_6_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_6.tscn")


func _on_button_7_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_7.tscn")


func _on_button_8_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_8.tscn")


func _on_button_9_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_9.tscn")


func _on_button_10_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_10.tscn")


func _on_button_11_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_11.tscn")


func _on_button_12_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_12.tscn")


func _on_button_13_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_13.tscn")


func _on_button_14_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/gl_14.tscn")
