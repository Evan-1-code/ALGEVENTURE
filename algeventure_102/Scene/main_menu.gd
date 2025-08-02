extends Control

func _on_play_pressed():
	print("Play button pressed")
	$ColorRect21/AnimationPlayer.play("fade_in")
	 # just play animation — nothing else yet

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		print("Fade finished — switching scene")
		get_tree().change_scene_to_file("res://Scene/town_map.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Fade finished — switching scene")
	if anim_name == "fade_in":
		get_tree().change_scene_to_file("res://Scene/town_map.tscn")
func _on_options_pressed():
	print("Options clicked!")

func _on_quit_pressed():
	get_tree().quit()
