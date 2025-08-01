extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Play clicked!")
	# get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_options_pressed():
	print("Options clicked!")
	# TODO: Show options popup or navigate to Options scene

func _on_quit_pressed():
	get_tree().quit()


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	pass # Replace with function body.
