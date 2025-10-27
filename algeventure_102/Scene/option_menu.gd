extends Control

# Buttons
@onready var skill_ladder_btn: Button  = $VBoxContainer/skill_Ladder_button
@onready var adaptive_mode_btn: Button = $VBoxContainer/AdaptiveModeButton
@onready var exit_btn: Button          = $VBoxContainer/exit_button
@onready var main_menu_btn: Button     = $VBoxContainer/main_menu_button
@onready var close_btn: Button         = $HBoxContainer/CloseButton   # Close button
@onready var Achievements_btn: Button  = $VBoxContainer/Achievements_button

# Volume controls
@onready var volume_slider: HSlider = $HBoxContainer/MusicVolumeSlider
@onready var volume_label: Label    = $HBoxContainer/VolumeLabel
@onready var mute_button: Button    = $HBoxContainer/MuteButton

# Background music
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# State
var last_volume: float = 0.5
var is_muted: bool = false

func _ready() -> void:
	# Let children receive clicks; containers stop input from leaking to the game
	mouse_filter = Control.MOUSE_FILTER_PASS
	if has_node("VBoxContainer"):
		$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	if has_node("HBoxContainer"):
		$HBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP

	# Background music
	if bgm_player:
		if bgm_player.stream == null:
			push_warning("No audio file assigned to BGMPlayer. Set one in the Inspector!")
		else:
			bgm_player.autoplay = true
			bgm_player.play()

	# Connect buttons (including Close)
	if close_btn:
		close_btn.pressed.connect(close)
	skill_ladder_btn.pressed.connect(_on_skill_ladder_pressed)
	adaptive_mode_btn.pressed.connect(_on_adaptive_mode_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	mute_button.pressed.connect(_on_mute_button_pressed)

	# Volume slider setup
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = last_volume
	if not volume_slider.value_changed.is_connected(Callable(self, "_on_music_volume_slider_value_changed")):
		volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)
	_on_music_volume_slider_value_changed(volume_slider.value)

	# Start hidden
	hide()  # same as: visible = false

func open() -> void:
	show()
	# If you want to pause gameplay while options are open, uncomment:
	# process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# get_tree().paused = true

func close() -> void:
	hide()
	# If you paused on open(), unpause here:
	# get_tree().paused = false

func toggle() -> void:
	visible = not visible

# --- Button Callbacks ---
func _on_skill_ladder_pressed() -> void:
	print("Skill Ladder pressed!")
	# get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/learning_portal.tscn")

func _on_adaptive_mode_pressed() -> void:
	print("Adaptive Mode pressed!")
	# get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Adaptive_Mode/Adaptive_Learning_Mode.tscn")

func _on_exit_pressed() -> void:
	print("Exit pressed, quitting...")
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	print("Main Menu pressed!")
	# get_tree().paused = false
	get_tree().change_scene_to_file("res://Tests/Main_menu.tscn")


func _on_mute_button_pressed() -> void:
	if is_muted:
		is_muted = false
		volume_slider.value = last_volume
		mute_button.text = "Mute"
	else:
		is_muted = true
		last_volume = volume_slider.value
		volume_slider.value = 0.0
		mute_button.text = "Unmute"

# --- Volume Slider Callback ---
func _on_music_volume_slider_value_changed(value: float) -> void:
	if bgm_player:
		bgm_player.volume_db = linear_to_db(value if value > 0.0 else 0.0001)
	var percent := int(value * 100.0)
	volume_label.text = "Music Volume: %d%%" % percent
	if not is_muted and value > 0.0:
		last_volume = value


func _on_achievements_button_pressed() -> void:
	print("Achievements pressed!")
	get_tree().change_scene_to_file("res://UI/achievements_menu.tscn")
