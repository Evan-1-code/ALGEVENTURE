extends Node

@export var JSON_PATH: String = "res://Scene/LearningPortal.tscn/ARlevel_problems/ALevel_1_problem.json"

enum Step { SHOW_PROBLEM, GIVEN, FORMULA, SOLVE, FEEDBACK, END }
var levels = []
var current_level_index := 0
var current_problem_index := 0
var current_step: Step = Step.SHOW_PROBLEM

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

var calculator_instance = null
var calculator_scene = preload("res://Scene/Calculatorscene/calculator.tscn")
var hint_system_instance = null
var hint_system_scene = preload("res://UI/HintSystem/HintSystem.tscn")

func _ready():
	ProblemLabel.bbcode_enabled = true
	_load_levels_from_json(JSON_PATH)
	_show_current_problem()
	if not NextButton.pressed.is_connected(_on_NextButton_pressed):
		NextButton.pressed.connect(_on_NextButton_pressed)
	
	# Set up hint button
	if HintButton and not HintButton.pressed.is_connected(_on_hint_button_pressed):
		HintButton.pressed.connect(_on_hint_button_pressed)
	
	# Initialize hint system
	if hint_system_scene:
		hint_system_instance = hint_system_scene.instantiate()
		add_child(hint_system_instance)

func _load_levels_from_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if typeof(json) == TYPE_ARRAY:
			levels = json
		else:
			push_error("JSON root is not an array!")
	else:
		push_error("Could not open JSON file.")

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
	
	# Show hint button if hint is available
	if HintButton:
		if problem.has("hint") and problem.has("steps"):
			HintButton.show()
		else:
			HintButton.hide()

func _show_given_inputs():
	current_step = Step.GIVEN
	GivenLabel.text = "Given:"
	GivenLabel.show()
	AnswerLabel.hide()
	NextButton.text = "Submit"
	NextButton.show()
	FormulaOptions.hide()
	FormulaFeedbackLabel.hide()
	SolveInput.hide()
	SolveFeedbackLabel.hide()
	CalculatorButton.hide()
	GivenInputContainer.show()
	# Clear previous
	for child in GivenInputContainer.get_children():
		child.queue_free()
	# Add new input fields
	var problem = _get_current_problem()
	if problem == null:
		push_error("No problem found in _show_given_inputs.")
		return
	if not problem.has("given"):
		push_error("Problem has no 'given' key in _show_given_inputs.")
		return
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
	if problem == null:
		push_error("No problem found in _try_submit_given.")
		return false
	if not problem.has("given"):
		push_error("Problem has no 'given' key in _try_submit_given.")
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
			push_error("Input line is null for key: %s in _try_submit_given." % given_key)
			return false
		var user_val = input_line.text.strip_edges()
		var solution_val = str(problem["given"][given_key])
		# Compare as floats, allow margin for float answers
		if abs(float(user_val) - float(solution_val)) > 0.01:
			return false
	return true

func _show_formula_choices():
	current_step = Step.FORMULA
	NextButton.hide()
	CalculatorButton.hide()
	FormulaOptions.show()
	FormulaFeedbackLabel.hide()

	# Clear previous options
	for c in FormulaOptions.get_children():
		c.queue_free()

	var problem = _get_current_problem()
	if problem == null:
		push_error("No problem found in _show_formula_choices.")
		return
	if not problem.has("formula"):
		push_error("Problem has no 'formula' key in _show_formula_choices.")
		return

	# ✅ Get correct + distractors from JSON
	var options = []
	options.append(problem["formula"])
	if problem.has("distractors"):
		for d in problem["distractors"]:
			options.append(d)

	# Shuffle all
	options.shuffle()

	# Create buttons
	for formula in options:
		var btn = Button.new()
		btn.text = formula
		btn.pressed.connect(_on_formula_selected.bind(formula))
		FormulaOptions.add_child(btn)


func _on_formula_selected(selected_formula):
	var problem = _get_current_problem()
	if problem == null:
		push_error("No problem found in _on_formula_selected.")
		return
	if not problem.has("formula"):
		push_error("Problem has no 'formula' key in _on_formula_selected.")
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
	if problem == null:
		push_error("No problem found in _try_submit_solve.")
		return false
	if not problem.has("answer"):
		push_error("Problem has no 'answer' key in _try_submit_solve.")
		return false
	var user_ans = SolveInput.text.strip_edges()
	var correct_ans = float(problem["answer"]) # Make sure it's a float
	var user_val = 0.0
	if user_ans.is_valid_float():
		user_val = float(user_ans)
	elif user_ans.is_valid_int():
		user_val = float(int(user_ans))
	else:
		# Not a valid number
		return false
	# Accept a small error for floats
	return abs(user_val - correct_ans) < 0.01

func _show_feedback():
	current_step = Step.FEEDBACK
	var level = null
	if current_level_index < levels.size():
		level = levels[current_level_index]
	if level == null or not level.has("problems"):
		NextButton.hide()
		ProblemLabel.text = "[b]All levels complete![/b]"
		return
	var last_problem = false
	if typeof(level["problems"]) == TYPE_ARRAY:
		last_problem = current_problem_index >= level["problems"].size() - 1

	if last_problem:
		ProblemLabel.text += "\n\n[b]Level Complete![/b]"
		if current_level_index < levels.size() - 1:
			_next_as_next_level()
		else:
			_next_as_back_to_topics()

	else:
		NextButton.text = "Next Problem"
		NextButton.show()
		CalculatorButton.hide()
		_hide_calculator()

func _on_NextButton_pressed():
	if current_step == Step.SHOW_PROBLEM:
		_show_given_inputs()
	elif current_step == Step.GIVEN:
		if _try_submit_given():
			GivenInputContainer.hide()
			_show_formula_choices()
		else:
			var problem = _get_current_problem()
			if problem != null and problem.has("text"):
				ProblemLabel.text = "[color=red]Try again![/color]\n" + str(problem["text"])
			else:
				ProblemLabel.text = "[color=red]Try again![/color]"
	elif current_step == Step.SOLVE:
		if _try_submit_solve():
			SolveFeedbackLabel.text = "[color=green]Correct![/color]"
			SolveFeedbackLabel.show()
			_show_feedback()
		else:
			SolveFeedbackLabel.text = "[color=red]Try again![/color]"
			SolveFeedbackLabel.show()
	elif current_step == Step.FEEDBACK:
		var level = null
		if current_level_index < levels.size():
			level = levels[current_level_index]
		if level == null or not level.has("problems"):
			ProblemLabel.text = "[b]All stages complete![/b]"
			NextButton.hide()
			return
		if typeof(level["problems"]) == TYPE_ARRAY and current_problem_index < level["problems"].size() - 1:
			current_problem_index += 1
			_show_current_problem()
		else:
			current_level_index += 1
			current_problem_index = 0
			if current_level_index < levels.size():
				_show_current_problem()
			else:
				ProblemLabel.text = "[b]All stages complete![/b]"
				NextButton.hide()

	elif current_step == Step.END:
		if NextButton.text == "Back to Topics":
			get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/arithmetic_levels.tscn")
		elif NextButton.text == "Next Level":
			current_level_index += 1
			current_problem_index = 0
			_show_current_problem()


func _on_calculator_button_pressed() -> void:
	if not is_instance_valid(calculator_instance):
		calculator_instance = calculator_scene.instantiate()
		get_tree().current_scene.add_child(calculator_instance)
		calculator_instance.custom_minimum_size = Vector2(250, 400)
		calculator_instance.position = Vector2(20, 20)

	# toggle
	if calculator_instance.visible:
		calculator_instance.hide()
	else:
		calculator_instance.show()


func _hide_calculator():
	if is_instance_valid(calculator_instance):
		calculator_instance.hide()

func _show_end_buttons():
	# Create two buttons dynamically
	var back_btn = Button.new()
	back_btn.text = "Back to Topics"
	back_btn.pressed.connect(_on_back_to_topics_pressed)
	add_child(back_btn)
	

	var proceed_btn = Button.new()
	if current_level_index < levels.size() - 1:
		proceed_btn.text = "Next Level"
		proceed_btn.pressed.connect(_on_next_level_pressed)
	else:
		proceed_btn.text = "Restart"
		proceed_btn.pressed.connect(_on_back_to_topics_pressed)  # Restart goes to topics
	add_child(proceed_btn) 
	
	ProgressManager.progress["al_1"] = true
	ProgressManager.save_progress()
	
	
	
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
	"""Handle hint button press"""
	var problem = _get_current_problem()
	if problem == null:
		return
	
	# Get hints and steps from the problem
	var hints: Array = []
	var steps: Array = []
	
	if problem.has("hint"):
		hints.append(problem["hint"])
	
	if problem.has("steps"):
		steps = problem["steps"]
	
	# Show hint system
	if hint_system_instance and hints.size() > 0:
		hint_system_instance.show_hint(hints, steps)
