extends CanvasLayer


var on_fade_finished = null  # ✅ dynamically typed

func fade_out(callback):
	print("Starting fade...")
	on_fade_finished = callback
	$ColorRect/AnimationPlayer.play("fade_out")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		print("Fade complete.")
		if on_fade_finished != null:
			on_fade_finished.call()



	
	   
