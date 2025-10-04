extends CanvasLayer

# Signals
signal hint_closed

# Node references
@onready var overlay = $Overlay
@onready var character = $Character
@onready var dialogue_box = $DialogueBox
@onready var hint_text = $DialogueBox/MarginContainer/VBoxContainer/HintText
@onready var step_text = $DialogueBox/MarginContainer/VBoxContainer/StepText
@onready var close_button = $DialogueBox/MarginContainer/VBoxContainer/CloseButton

# Hint data
var current_hints: Array = []
var current_steps: Array = []
var current_index: int = 0

# Animation parameters
var slide_duration: float = 0.5
var character_start_y: float = 0
var character_target_y: float = 0

func _ready():
	# Hide everything initially
	hide_hint_system()
	
	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Set up character position
	if character:
		character_start_y = get_viewport_rect().size.y
		character_target_y = get_viewport_rect().size.y - 200

func show_hint(hints: Array, steps: Array):
	"""Display hint system with provided hints and step-by-step instructions"""
	if hints.is_empty():
		push_warning("No hints provided to hint system")
		return
	
	current_hints = hints
	current_steps = steps if steps.size() > 0 else []
	current_index = 0
	
	# Show overlay
	overlay.visible = true
	overlay.modulate = Color(0, 0, 0, 0)
	
	# Position character at bottom (off-screen)
	if character:
		character.position.y = character_start_y
		character.visible = true
	
	# Hide dialogue box initially
	dialogue_box.visible = false
	
	# Animate overlay fade in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate", Color(0, 0, 0, 0.7), 0.3)
	
	# Animate character slide up
	if character:
		tween.tween_property(character, "position:y", character_target_y, slide_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Show dialogue after character slides up
	tween.chain()
	tween.tween_callback(_show_dialogue)

func _show_dialogue():
	"""Show the dialogue box with current hint"""
	dialogue_box.visible = true
	dialogue_box.modulate = Color(1, 1, 1, 0)
	
	# Update text
	_update_hint_text()
	
	# Fade in dialogue
	var tween = create_tween()
	tween.tween_property(dialogue_box, "modulate", Color(1, 1, 1, 1), 0.3)

func _update_hint_text():
	"""Update the hint and step text"""
	if current_index < current_hints.size():
		hint_text.text = current_hints[current_index]
	else:
		hint_text.text = "No more hints available."
	
	# Update steps if available
	if current_steps.size() > 0:
		var steps_formatted = ""
		for i in range(current_steps.size()):
			steps_formatted += str(i + 1) + ". " + current_steps[i] + "\n"
		step_text.text = steps_formatted
		step_text.visible = true
	else:
		step_text.visible = false

func hide_hint_system():
	"""Hide the entire hint system"""
	overlay.visible = false
	if character:
		character.visible = false
	dialogue_box.visible = false

func _on_close_button_pressed():
	"""Handle close button press"""
	# Animate everything out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out dialogue
	tween.tween_property(dialogue_box, "modulate", Color(1, 1, 1, 0), 0.3)
	
	# Slide character down
	if character:
		tween.tween_property(character, "position:y", character_start_y, slide_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	# Fade out overlay
	tween.tween_property(overlay, "modulate", Color(0, 0, 0, 0), 0.3)
	
	# Hide everything after animation
	tween.chain()
	tween.tween_callback(hide_hint_system)
	tween.tween_callback(func(): emit_signal("hint_closed"))

func _input(event):
	"""Allow ESC key to close hint system"""
	if overlay.visible and event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()
		get_viewport().set_input_as_handled()
