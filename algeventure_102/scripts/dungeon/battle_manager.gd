extends Node
class_name BattleManager

## Manages 3-stage question battles

signal battle_started(enemy: EnemyData)
signal stage_changed(stage: int)
signal player_damaged(damage: float)
signal enemy_damaged(damage: int)
signal battle_ended(victory: bool)
signal hint_requested(stage: int)

enum BattleStage {
	GIVEN = 1,
	FORMULA = 2,
	ANSWER = 3
}

var current_enemy: EnemyData
var current_stage: BattleStage = BattleStage.GIVEN
var player_state: PlayerState
var config: DungeonConfig
var calculator_visible: bool = false

# Question data structure (to be populated by external system)
var current_question: Dictionary = {}

func _ready() -> void:
	if not config:
		config = DungeonConfig.new()

func start_battle(enemy: EnemyData, state: PlayerState) -> void:
	current_enemy = enemy
	player_state = state
	current_stage = BattleStage.GIVEN
	calculator_visible = false
	
	_build_question_for_enemy(enemy)
	battle_started.emit(enemy)
	stage_changed.emit(current_stage)

func _build_question_for_enemy(enemy: EnemyData) -> void:
	# This is a placeholder - actual question generation should be done
	# by a separate question generator based on dungeon type and difficulty
	current_question = {
		"stages": {
			BattleStage.GIVEN: {
				"question": "What is the given in this problem: 'Solve for x: 2x + 5 = 15'?",
				"choices": ["2x + 5 = 15", "x = 5", "2x", "15"],
				"correct": 0,
				"hint": "The given is the entire equation that needs to be solved."
			},
			BattleStage.FORMULA: {
				"question": "Which formula or approach should you use?",
				"choices": ["Subtract 5 from both sides", "Divide by 2", "Add 5 to both sides", "Multiply by 2"],
				"correct": 0,
				"hint": "You need to isolate the variable term first."
			},
			BattleStage.ANSWER: {
				"question": "What is the value of x?",
				"answer": 5.0,
				"tolerance": 0.001,
				"hint": "After subtracting 5 and dividing by 2, you should get the answer."
			}
		}
	}

func submit_stage_answer(answer_index: int = -1, numeric_answer: float = 0.0) -> bool:
	var stage_data = current_question["stages"].get(current_stage, {})
	var is_correct = false
	
	match current_stage:
		BattleStage.GIVEN, BattleStage.FORMULA:
			# Multiple choice
			is_correct = (answer_index == stage_data.get("correct", -1))
		
		BattleStage.ANSWER:
			# Numeric answer
			var correct_answer = stage_data.get("answer", 0.0)
			var tolerance = stage_data.get("tolerance", 0.001)
			is_correct = abs(numeric_answer - correct_answer) <= tolerance
	
	if is_correct:
		_handle_correct_answer()
	else:
		_handle_wrong_answer()
	
	return is_correct

func _handle_correct_answer() -> void:
	if current_stage == BattleStage.ANSWER:
		# Final stage correct - damage enemy
		current_enemy.take_damage(1)
		enemy_damaged.emit(1)
		
		if current_enemy.is_defeated:
			_end_battle(true)
		else:
			# Multi-HP enemy - start new question cycle
			current_stage = BattleStage.GIVEN
			_build_question_for_enemy(current_enemy)
			stage_changed.emit(current_stage)
	else:
		# Advance to next stage
		current_stage = current_stage + 1 as BattleStage
		stage_changed.emit(current_stage)

func _handle_wrong_answer() -> void:
	var damage = config.damage_per_wrong_answer
	if player_state.inventory.get("armor", false):
		damage = config.damage_with_armor
	
	player_state.take_damage(damage)
	player_damaged.emit(damage)
	
	if not player_state.is_alive():
		_end_battle(false)

func _end_battle(victory: bool) -> void:
	if victory:
		# Award XP
		player_state.add_xp(current_enemy.xp_reward)
	
	battle_ended.emit(victory)
	current_enemy = null
	current_question.clear()

func use_scroll() -> bool:
	if current_stage == BattleStage.ANSWER:
		return false  # Can't use scroll on typed answer
	
	if player_state.use_scroll():
		# Scroll removes 1-2 wrong options
		return true
	return false

func toggle_calculator() -> void:
	calculator_visible = not calculator_visible

func request_hint() -> void:
	hint_requested.emit(current_stage)

func get_stage_hint() -> String:
	var stage_data = current_question["stages"].get(current_stage, {})
	return stage_data.get("hint", "No hint available.")

func get_stage_question() -> String:
	var stage_data = current_question["stages"].get(current_stage, {})
	return stage_data.get("question", "")

func get_stage_choices() -> Array:
	var stage_data = current_question["stages"].get(current_stage, {})
	return stage_data.get("choices", [])

func is_battle_active() -> bool:
	return current_enemy != null

func get_enemy_taunt() -> String:
	if current_enemy and not current_enemy.taunts.is_empty():
		return current_enemy.taunts[randi() % current_enemy.taunts.size()]
	return ""
