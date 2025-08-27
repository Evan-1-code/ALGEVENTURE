extends Node

@export var JSON_PATH: String = "res://Scene/LearningPortal.tscn/ARlevel_problems/ALevel_1_problem.json"

enum Step { SHOW_PROBLEM, GIVEN, FORMULA, SOLVE, FEEDBACK }
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

func _ready():
	_load_levels_from_json(JSON_PATH)
	_show_current_problem()
	if not NextButton.pressed.is_connected(_on_NextButton_pressed):
		NextButton.pressed.connect(_on_NextButton_pressed)

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
		NextButton.hide()
		GivenInputContainer.hide()
		FormulaOptions.hide()
		FormulaFeedbackLabel.hide()
		SolveInput.hide()
		SolveFeedbackLabel.hide()
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

func _show_given_inputs():
	current_step = Step.GIVEN
	NextButton.text = "Submit"
	NextButton.show()
	FormulaOptions.hide()
	FormulaFeedbackLabel.hide()
	SolveInput.hide()
	SolveFeedbackLabel.hide()
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
	var options = [problem["formula"]]
	while options.size() < 3:
		var distractor = "Speed = Time / Distance"
		if distractor not in options:
			options.append(distractor)
		else:
			options.append("Distance = Speed x Time")
	options.shuffle()
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
		_show_solve_phase()
	else:
		FormulaFeedbackLabel.text = "[color=red]Not quite! Try again.[/color]"
		FormulaFeedbackLabel.show()

func _show_solve_phase():
	current_step = Step.SOLVE
	NextButton.text = "Submit"
	NextButton.show()
	FormulaOptions.hide()
	SolveInput.show()
	SolveFeedbackLabel.hide()
	SolveInput.text = ""

func _try_submit_solve() -> bool:
	var problem = _get_current_problem()
	if problem == null:
		push_error("No problem found in _try_submit_solve.")
		return false
	if not problem.has("answer"):
		push_error("Problem has no 'answer' key in _try_submit_solve.")
		return false
	var user_ans = SolveInput.text.strip_edges()
	var correct_ans = str(problem["answer"])
	return user_ans == correct_ans

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
	NextButton.text = "Next Problem" if not last_problem else "Next Level"
	NextButton.show()

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
			ProblemLabel.text = "[b]All levels complete![/b]"
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
				ProblemLabel.text = "[b]All levels complete![/b]"
				NextButton.hide()
