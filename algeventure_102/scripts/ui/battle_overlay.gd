extends CanvasLayer

## Battle overlay UI for 3-stage question battles

signal answer_submitted(answer_index: int, numeric_answer: float)
signal calculator_toggled()
signal scroll_used()
signal hint_requested()

@onready var enemy_info = $Panel/VBoxContainer/EnemyInfo
@onready var question_label = $Panel/VBoxContainer/QuestionLabel
@onready var choice_container = $Panel/VBoxContainer/ChoiceContainer
@onready var answer_input = $Panel/VBoxContainer/AnswerInput
@onready var submit_button = $Panel/VBoxContainer/SubmitButton
@onready var calculator_button = $Panel/VBoxContainer/BottomBar/CalculatorButton
@onready var scroll_button = $Panel/VBoxContainer/BottomBar/ScrollButton
@onready var hint_button = $Panel/VBoxContainer/BottomBar/HintButton

var battle_manager: BattleManager
var current_stage: int = 1

func _ready() -> void:
	hide()

func initialize(manager: BattleManager) -> void:
	battle_manager = manager
	_connect_manager_signals()

func _connect_manager_signals() -> void:
	if battle_manager:
		battle_manager.battle_started.connect(_on_battle_started)
		battle_manager.stage_changed.connect(_on_stage_changed)
		battle_manager.battle_ended.connect(_on_battle_ended)

func _on_battle_started(enemy: EnemyData) -> void:
	show()
	_update_enemy_info(enemy)
	_update_stage_display()

func _on_stage_changed(stage: int) -> void:
	current_stage = stage
	_update_stage_display()

func _on_battle_ended(victory: bool) -> void:
	hide()
	if victory:
		_show_victory_message()
	else:
		_show_defeat_message()

func _update_enemy_info(enemy: EnemyData) -> void:
	if enemy_info:
		enemy_info.text = "Enemy: %s (HP: %d)" % [enemy.enemy_type.capitalize(), enemy.hp]

func _update_stage_display() -> void:
	if not battle_manager:
		return
	
	# Update question text
	if question_label:
		question_label.text = battle_manager.get_stage_question()
	
	# Clear previous choices
	if choice_container:
		for child in choice_container.get_children():
			child.queue_free()
	
	# Show appropriate input based on stage
	match current_stage:
		BattleManager.BattleStage.GIVEN, BattleManager.BattleStage.FORMULA:
			# Multiple choice
			if answer_input:
				answer_input.hide()
			_create_choice_buttons()
		
		BattleManager.BattleStage.ANSWER:
			# Numeric input
			if choice_container:
				for child in choice_container.get_children():
					child.queue_free()
			if answer_input:
				answer_input.show()
				answer_input.clear()

func _create_choice_buttons() -> void:
	if not battle_manager or not choice_container:
		return
	
	var choices = battle_manager.get_stage_choices()
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]
		button.pressed.connect(_on_choice_selected.bind(i))
		choice_container.add_child(button)

func _on_choice_selected(index: int) -> void:
	if battle_manager:
		battle_manager.submit_stage_answer(index)

func _on_submit_button_pressed() -> void:
	if not battle_manager or current_stage != BattleManager.BattleStage.ANSWER:
		return
	
	if answer_input:
		var numeric_answer = answer_input.text.to_float()
		battle_manager.submit_stage_answer(-1, numeric_answer)

func _on_calculator_button_pressed() -> void:
	if battle_manager:
		battle_manager.toggle_calculator()
	calculator_toggled.emit()

func _on_scroll_button_pressed() -> void:
	if battle_manager and battle_manager.use_scroll():
		scroll_used.emit()
		_update_stage_display()  # Refresh to show removed options

func _on_hint_button_pressed() -> void:
	if battle_manager:
		battle_manager.request_hint()
	hint_requested.emit()

func _show_victory_message() -> void:
	print("Victory!")
	# TODO: Show victory animation/message

func _show_defeat_message() -> void:
	print("Defeat!")
	# TODO: Show defeat animation/message
