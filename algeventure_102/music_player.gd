extends AudioStreamPlayer

func _ready():
	# Play automatically if not already playing
	if stream != null and not playing:
		play()

func set_music_volume(volume: float):
	volume_db = linear_to_db(clamp(volume, 0.0, 1.0))

func mute_music():
	volume_db = -80
