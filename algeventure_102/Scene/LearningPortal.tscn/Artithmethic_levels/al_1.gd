extends Node

@export var JSON_PATH: String = "res://Scene/LearningPortal.tscn/ARlevel_problems/ALevel_2_problem.json"

enum Step { SHOW_PROBLEM, GIVEN, FORMULA, SOLVE, FEEDBACK, END }
var levels = []
var current_level_index := 0
var current_problem_index := 0
var current_step: Step = Step.SHOW_PROBLEM
@export var level_type: String = "al"  
@export var level_number: int = 1 

@onready var ProblemLabel = $ProblemLabel
@onready var NextButton = $NextButton
@onready var GivenInputContainer = $GivenInputContainer
@onready var FormulaOptions = $FormulaOptions
@onready var FormulaFeedbackLabel = $FormulaFeedbackLabel
@onready var SolveInput = $SolveInput
@onready var SolveFeedbackLabel = $SolveFeedbackLabel
@onready var CalculatorButton = $CalculatorButton
@onready var GivenLabel = $Given
@onready var AnswerLabel = $SolutionSteps
@onready var HintButton = $HintButton
@onready var settings_overlay := $option_menu # adjust the path to your overlay
@onready var color_rect = $ColorRect

var calculator_instance = null
var calculator_scene = preload("res://Scene/Calculatorscene/calculator.tscn")
var hint_system_instance = null
var hint_system_scene = preload("res://UI/HintSystem/HintSystem.tscn")

func _ready():
	ProblemLabel.bbcode_enabled = true
	_load_levels_from_json(JSON_PATH)
	current_level_index = 0
	current_problem_index = 0
	current_step = Step.SHOW_PROBLEM
	_show_current_problem()
	if not NextButton.pressed.is_connected(_on_NextButton_pressed):
		NextButton.pressed.connect(_on_NextButton_pressed)
	if HintButton and not HintButton.pressed.is_connected(_on_hint_button_pressed):
		HintButton.pressed.connect(_on_hint_button_pressed)
	if CalculatorButton and not CalculatorButton.pressed.is_connected(_on_calculator_button_pressed):
		CalculatorButton.pressed.connect(_on_calculator_button_pressed)
	if hint_system_scene:
		hint_system_instance = hint_system_scene.instantiate()
		add_child(hint_system_instance)
	MusicPlayer.play()
	color_rect.color = Color("007580")
	ProblemLabel.bbcode_enabled = true
	SolveFeedbackLabel.bbcode_enabled = true

func set_json_path(new_path: String) -> void:
	JSON_PATH = new_path
	_load_levels_from_json(JSON_PATH)
	_show_current_problem()

func _load_levels_from_json(path):
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: " + path)
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if typeof(json) == TYPE_ARRAY:
			levels = json
		else:
			push_error("JSON root is not an array!")
	else:
		push_error("Could not open JSON file.")
	MusicPlayer.play()
	MusicPlayer.set_music_volume(0.5)
	MusicPlayer.mute_music()

func _get_current_problem():
	if levels.size() == 0:
		push_error("Levels array is empty!")
		return null
	if current_level_index < 0 or current_level_index >= levels.size():
		push_error("current_level_index %d out of bounds" % current_level_index)
		return null
	var level = levels[current_level_index]
	if typeof(level) != TYPE_DICTIONARY or not level.has("problems"):
		push_error("Level has no 'problems' key: %s" % str(level))
		return null
	var problems = level["problems"]
	if current_problem_index < 0 or current_problem_index >= problems.size():
		push_error("current_problem_index %d out of bounds" % current_problem_index)
		return null
	return problems[current_problem_index]

func _show_current_problem():
	current_step = Step.SHOW_PROBLEM
	var problem = _get_current_problem()
	if problem == null:
		ProblemLabel.text = "No more problems."
		GivenLabel.hide()
		AnswerLabel.hide()
		NextButton.hide()
		GivenInputContainer.hide()
		FormulaOptions.hide()
		FormulaFeedbackLabel.hide()
		SolveInput.hide()
		SolveFeedbackLabel.hide()
		if HintButton:
			HintButton.hide()
		return
	if not problem.has("text"):
		ProblemLabel.text = "[b]Problem text missing.[/b]"
		_show_all_levels_complete()
		return
	ProblemLabel.text = "[b]Problem:[/b]\n" + str(problem["text"])
	NextButton.text = "Next"
	NextButton.show()
	GivenInputContainer.hide()
	FormulaOptions.hide()
	FormulaFeedbackLabel.hide()
	SolveInput.hide()
	SolveFeedbackLabel.hide()
	CalculatorButton.hide()
	if HintButton:
		if problem.has("hint") and problem.has("steps"):
			HintButton.show()
		else:
			HintButton.hide()

func _show_given_inputs():
	current_step = Step.GIVEN
	GivenLabel.text = "Given:"
	GivenInputContainer.show()
	GivenLabel.show()
	AnswerLabel.hide()
	NextButton.text = "Submit"
	NextButton.show()
	FormulaOptions.hide()
	SolveInput.hide()
	SolveFeedbackLabel.hide()
	CalculatorButton.hide()
	for child in GivenInputContainer.get_children():
		child.queue_free()
	var problem = _get_current_problem()
	if problem != null and problem.has("given"):
		for given_key in problem["given"].keys():
			var hbox = HBoxContainer.new()
			var label = Label.new()
			label.text = "%s = " % given_key
			var input = LineEdit.new()
			input.name = given_key
			hbox.add_child(label)
			hbox.add_child(input)
			GivenInputContainer.add_child(hbox)

func _try_submit_given() -> bool:
	var problem = _get_current_problem()
	if problem == null or not problem.has("given"):
		return false
	for given_key in problem["given"].keys():
		var input_line = null
		for hbox in GivenInputContainer.get_children():
			if hbox is HBoxContainer:
				var label = hbox.get_child(0)
				var input = hbox.get_child(1)
				if label.text.begins_with("%s = " % given_key):
					input_line = input
					break
		if input_line == null:
			return false
		var user_val = input_line.text.strip_edges()
		var solution_val = str(problem["given"][given_key])
		if abs(float(user_val) - float(solution_val)) > 0.01:
			return false
	return true

func _show_formula_choices():
	current_step = Step.FORMULA
	NextButton.hide()
	CalculatorButton.hide()
	FormulaOptions.show()
	FormulaFeedbackLabel.hide()
	for c in FormulaOptions.get_children():
		c.queue_free()
	var problem = _get_current_problem()
	if problem == null or not problem.has("formula"):
		return
	var options = []
	options.append(problem["formula"])
	if problem.has("distractors"):
		for d in problem["distractors"]:
			options.append(d)
	options.shuffle()
	for formula in options:
		var btn = Button.new()
		btn.text = formula
		btn.pressed.connect(_on_formula_selected.bind(formula))
		FormulaOptions.add_child(btn)

func _on_formula_selected(selected_formula):
	var problem = _get_current_problem()
	if problem == null or not problem.has("formula"):
		return
	if selected_formula == problem["formula"]:
		FormulaFeedbackLabel.hide()
		FormulaOptions.hide()
		ProblemLabel.text += "\n\n[b]Correct Formula:[/b] " + selected_formula
		_show_solve_phase()
	else:
		FormulaFeedbackLabel.text = "[color=red]Not quite! Try again.[/color]"
		FormulaFeedbackLabel.show()
		CalculatorButton.hide()

func _show_solve_phase():
	current_step = Step.SOLVE
	GivenLabel.hide()
	AnswerLabel.text = "Answer:"
	AnswerLabel.show()
	NextButton.text = "Submit"
	NextButton.show()
	FormulaOptions.hide()
	SolveInput.show()
	SolveFeedbackLabel.hide()
	SolveInput.text = ""
	CalculatorButton.show()

func _try_submit_solve() -> bool:
	var problem = _get_current_problem()
	if problem == null or not problem.has("answer"):
		return false
	var user_ans = SolveInput.text.strip_edges()
	var correct_ans = float(problem["answer"])
	var user_val = 0.0
	if user_ans.is_valid_float():
		user_val = float(user_ans)
	elif user_ans.is_valid_int():
		user_val = float(int(user_ans))
	else:
		return false
	return abs(user_val - correct_ans) < 0.01

func _show_feedback():
	current_step = Step.FEEDBACK
	var level = levels[current_level_index]
	var last_problem = current_problem_index >= level["problems"].size() - 1
	if last_problem:
		ProblemLabel.text += "\n\n[b]Level Complete![/b]"
		_show_end_buttons()
	else:
		NextButton.text = "Next Problem"
		NextButton.show()
		CalculatorButton.hide()
		_hide_calculator()

func _on_NextButton_pressed():
	match NextButton.text:
		"Next":
			_show_given_inputs()
		"Submit":
			if current_step == Step.GIVEN:
				if _try_submit_given():
					GivenInputContainer.hide()
					_show_formula_choices()
				else:
					var problem = _get_current_problem()
					var motivational_messages = [
						"Great effort!",
						"You're making progress!",
						"Every try gets you closer!"
					]
					var chosen_message = motivational_messages[randi() % motivational_messages.size()]
					if problem != null and problem.has("text"):
						ProblemLabel.text = "[color=red]Try again![/color]\n" + str(problem["text"]) + "\n\n" + "[color=blue]" + chosen_message + "[/color]"
					else:
						ProblemLabel.text = "[color=red]Try again![/color]\n" + "[color=blue]" + chosen_message + "[/color]"
			elif current_step == Step.SOLVE:
				if _try_submit_solve():
					var motivational_messages = [
						"Great effort!",
						"You're making progress!",
						"Every try gets you closer!"
					]
					var chosen_message = motivational_messages[randi() % motivational_messages.size()]
					SolveFeedbackLabel.text = "[color=green]Correct![/color]\n[color=blue]" + chosen_message + "[/color]"
					SolveFeedbackLabel.show()
					_show_feedback()
				else:
					var motivational_messages = [
						"Great effort!",
						"You're making progress!",
						"Every try gets you closer!"
					]
					var chosen_message = motivational_messages[randi() % motivational_messages.size()]
					SolveFeedbackLabel.text = "[color=red]Try again![/color]\n[color=blue]" + chosen_message + "[/color]"
					SolveFeedbackLabel.show()
		"Next Problem":
			current_problem_index += 1
			_show_current_problem()
		"Next Level":
			current_level_index += 1
			current_problem_index = 0
			if current_level_index < levels.size():
				_show_current_problem()
			else:
				_show_all_levels_complete()
		"Back to Topics":
			_on_back_to_topics_pressed()
		_:
			pass

func _on_calculator_button_pressed() -> void:
	if not is_instance_valid(calculator_instance):
		calculator_instance = calculator_scene.instantiate()
		get_tree().current_scene.add_child(calculator_instance)
		calculator_instance.custom_minimum_size = Vector2(250, 400)
		calculator_instance.position = Vector2(20, 20)
	else:
		calculator_instance.visible = !calculator_instance.visible

func _hide_calculator():
	if is_instance_valid(calculator_instance):
		calculator_instance.hide()

func _show_end_buttons():
	NextButton.text = "Next Level"
	NextButton.show()
	ProgressManager.mark_complete("%s_%d" % [level_type, level_number])

func _show_all_levels_complete():
	ProblemLabel.text = "[b]All stages complete![/b]"
	NextButton.text = "Back to Topics"
	NextButton.show()
	ProgressManager.mark_complete("%s_%d" % [level_type, current_level_index + 1])

func _on_back_to_topics_pressed():
	get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/learning_portal.tscn")

func _on_next_level_pressed():
	current_level_index += 1
	current_problem_index = 0
	if current_level_index < levels.size():
		_show_current_problem()
	else:
		ProblemLabel.text = "[b]All stages complete![/b]"

func _next_as_back_to_topics():
	current_step = Step.END
	NextButton.text = "Back to Topics"
	NextButton.show()
	CalculatorButton.hide()
	_hide_calculator()

func _next_as_next_level():
	current_step = Step.END
	NextButton.text = "Next Level"
	NextButton.show()
	CalculatorButton.hide()
	_hide_calculator()

func _on_hint_button_pressed():
	var problem = _get_current_problem()
	if problem == null:
		return
	
	var hints: Array = []
	var steps: Array = []
	
	if problem.has("hint"):
		hints.append(problem["hint"])
	
	if problem.has("steps"):
		steps = problem["steps"]
	
	if hint_system_instance and hints.size() > 0:
		hint_system_instance.show_hint(hints, steps)

func _on_settings_button_pressed() -> void:
	settings_overlay.open()
	settings_overlay.show()
