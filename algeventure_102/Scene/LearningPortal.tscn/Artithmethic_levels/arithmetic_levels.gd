extends Control

@onready var al2_button: Button = $HBoxContainer/Button2
@onready var al3_button: Button = $HBoxContainer/Button3
@onready var al4_button: Button = $HBoxContainer/Button4
@onready var al5_button: Button = $HBoxContainer/Button5
@onready var al6_button: Button = $HBoxContainer/Button6
@onready var al7_button: Button = $HBoxContainer/Button7

func _ready():
	al2_button.disabled = not ProgressManager.progress["al_1"]
	al3_button.disabled = not ProgressManager.progress["al_2"]
	al4_button.disabled = not ProgressManager.progress["al_3"]
	al5_button.disabled = not ProgressManager.progress["al_4"]
	al6_button.disabled = not ProgressManager.progress["al_5"]
	al7_button.disabled = not ProgressManager.progress["al_6"]

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
