extends Control

# Buttons
@onready var skill_ladder_btn: Button = $VBoxContainer/skill_Ladder_button
@onready var adaptive_mode_btn: Button = $VBoxContainer/AdaptiveModeButton
@onready var exit_btn: Button = $VBoxContainer/exit_button
@onready var main_menu_btn: Button = $VBoxContainer/main_menu_button

# Volume controls
@onready var volume_slider: HSlider = $HBoxContainer/MusicVolumeSlider
@onready var volume_label: Label = $HBoxContainer/VolumeLabel
@onready var mute_button: Button = $HBoxContainer/MuteButton

# Background music
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# State
var last_volume: float = 0.5
var is_muted: bool = false


func _ready() -> void:
	# --- Setup Background Music ---
	if bgm_player.stream == null:
		push_warning("No audio file assigned to BGMPlayer. Set one in the Inspector!")
	else:
		bgm_player.autoplay = true
		bgm_player.play()

	# --- Connect Buttons ---
	skill_ladder_btn.pressed.connect(_on_skill_ladder_pressed)
	adaptive_mode_btn.pressed.connect(_on_adaptive_mode_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	mute_button.pressed.connect(_on_mute_button_pressed)

	# --- Setup Volume Slider ---
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = last_volume
	_on_music_volume_slider_value_changed(volume_slider.value)

	if not volume_slider.is_connected("value_changed", Callable(self, "_on_music_volume_slider_value_changed")):
		volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)


# --- Button Callbacks ---
func _on_skill_ladder_pressed() -> void:
	print("Skill Ladder pressed!")
	# get_tree().change_scene_to_file("res://scenes/SkillLadder.tscn")

func _on_adaptive_mode_pressed() -> void:
	print("Adaptive Mode pressed!")
	# get_tree().change_scene_to_file("res://scenes/AdaptiveMode.tscn")

func _on_exit_pressed() -> void:
	print("Exit pressed, quitting...")
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	print("Main Menu pressed!")
	# get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_mute_button_pressed() -> void:
	if is_muted:
		# Unmute → restore last volume
		is_muted = false
		volume_slider.value = last_volume
		mute_button.text = "Mute"
	else:
		# Mute → save current volume, set to 0
		is_muted = true
		last_volume = volume_slider.value
		volume_slider.value = 0
		mute_button.text = "Unmute"


# --- Volume Slider Callback ---
func _on_music_volume_slider_value_changed(value: float) -> void:
	if bgm_player:
		bgm_player.volume_db = linear_to_db(value if value > 0 else 0.0001)

	var percent := int(value * 100)
	volume_label.text = "Music Volume: %d%%" % percent

	if not is_muted and value > 0:
		last_volume = value
