extends Node

@export_file("*.json") var JSON_PATH: String = ""

# REQUIRED: "arithmetic" or "geometric" (lowercase)
@export var path_name: String = "arithmetic"

# REQUIRED: Progress key the level select uses to mark this level cleared (e.g., "al_1" or "gl_1")
@export var progress_key_for_this_level: String = ""

# REQUIRED: Scene to return to for this path’s level select
@export_file("*.tscn") var back_to_topics_scene: String = ""

enum Step { SHOW_PROBLEM, GIVEN, FORMULA, SOLVE, FEEDBACK, END }
var levels: Array = []
var current_level_index: int = 0
var current_problem_index: int = 0
var current_step: Step = Step.SHOW_PROBLEM
var _level_reported: bool = false

@onready var ProblemLabel = $ProblemLabel
@onready var NextButton: Button = $NextButton
@onready var GivenInputContainer: VBoxContainer = $GivenInputContainer
@onready var FormulaOptions: VBoxContainer = $FormulaOptions
@onready var FormulaFeedbackLabel: Label = $FormulaFeedbackLabel
@onready var SolveInput: LineEdit = $SolveInput
@onready var SolveFeedbackLabel: Label = $SolveFeedbackLabel
@onready var CalculatorButton: Button = $CalculatorButton
@onready var GivenLabel: Label = $Given
@onready var AnswerLabel: Label = $SolutionSteps

var calculator_instance: Control = null
var calculator_scene: PackedScene = preload("res://Scene/Calculatorscene/calculator.tscn")

@onready var settings_overlay := $option_menu # adjust the path to your overlay

func _on_settings_button_pressed() -> void:
	settings_overlay.open()

func _ready() -> void:
	# Normalize path_name for safety
	path_name = path_name.strip_edges().to_lower()

	# If ProblemLabel is a RichTextLabel in your scene, this is valid; otherwise remove this line.
	if ProblemLabel.has_method("set_bbcode_enabled"):
		ProblemLabel.bbcode_enabled = true

	_load_levels_from_json(JSON_PATH)
	_show_current_problem()
	if not NextButton.pressed.is_connected(_on_NextButton_pressed):
		NextButton.pressed.connect(_on_NextButton_pressed)
	# Save the current scene's path before switching
	get_tree().set_meta("previous_scene_path", get_tree().current_scene.scene_file_path)

	print("Progress at startup:", UserDataManager.data["progress"])
func _load_levels_from_json(path: String) -> void:
	var p: String = path.strip_edges()
	if p == "" or not FileAccess.file_exists(p):
		push_error("Could not open JSON file: %s" % p)
		return
	var file := FileAccess.open(p, FileAccess.READ)
	if file == null:
		push_error("Could not open JSON file: %s" % p)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		levels = parsed as Array
	else:
		push_error("JSON root is not an array in %s" % p)

func _get_current_problem() -> Variant:
	if levels.is_empty():
		push_error("Levels array is empty!")
		return null
	if current_level_index < 0 or current_level_index >= levels.size():
		push_error("current_level_index %d out of bounds" % current_level_index)
		return null
	var level: Variant = levels[current_level_index]
	if typeof(level) != TYPE_DICTIONARY or not (level as Dictionary).has("problems"):
		push_error("Level has no 'problems' key: %s" % str(level))
		return null
	var problems: Array = ((level as Dictionary).get("problems", []) as Array)
	if current_problem_index < 0 or current_problem_index >= problems.size():
		push_error("current_problem_index %d out of bounds" % current_problem_index)
		return null
	return problems[current_problem_index]

func _show_current_problem() -> void:
	# Starting a level: reset report guard
	if current_problem_index == 0:
		_level_reported = false

	current_step = Step.SHOW_PROBLEM
	var problem: Variant = _get_current_problem()
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
		return
	if not (problem as Dictionary).has("text"):
		ProblemLabel.text = "[b]Problem text missing.[/b]"
		return
	ProblemLabel.text = "[b]Problem:[/b]\n" + str((problem as Dictionary)["text"])
	NextButton.text = "Next"
	NextButton.show()
	GivenInputContainer.hide()
	FormulaOptions.hide()
	FormulaFeedbackLabel.hide()
	SolveInput.hide()
	SolveFeedbackLabel.hide()
	CalculatorButton.hide()

func _show_given_inputs() -> void:
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
	var problem: Variant = _get_current_problem()
	if problem == null:
		push_error("No problem found in _show_given_inputs.")
		return
	if not (problem as Dictionary).has("given"):
		push_error("Problem has no 'given' key in _show_given_inputs.")
		return
	for given_key in ((problem as Dictionary)["given"] as Dictionary).keys():
		var hbox := HBoxContainer.new()
		var label := Label.new()
		label.text = "%s = " % given_key
		var input := LineEdit.new()
		input.name = str(given_key)
		hbox.add_child(label)
		hbox.add_child(input)
		GivenInputContainer.add_child(hbox)

func _try_submit_given() -> bool:
	var problem: Variant = _get_current_problem()
	if problem == null:
		push_error("No problem found in _try_submit_given.")
		return false
	if not (problem as Dictionary).has("given"):
		push_error("Problem has no 'given' key in _try_submit_given.")
		return false
	for given_key in ((problem as Dictionary)["given"] as Dictionary).keys():
		var input_line: LineEdit = null
		for hbox in GivenInputContainer.get_children():
			if hbox is HBoxContainer:
				var label: Label = (hbox.get_child(0) as Label)
				var input: LineEdit = (hbox.get_child(1) as LineEdit)
				if label.text.begins_with("%s = " % given_key):
					input_line = input
					break
		if input_line == null:
			push_error("Input line is null for key: %s in _try_submit_given." % given_key)
			return false
		var user_val: String = input_line.text.strip_edges()
		var solution_val: String = str(((problem as Dictionary)["given"] as Dictionary)[given_key])
		# Compare as floats, allow margin for float answers
		if abs(float(user_val) - float(solution_val)) > 0.01:
			return false
	return true

func _show_formula_choices() -> void:
	current_step = Step.FORMULA
	NextButton.hide()
	CalculatorButton.hide()
	FormulaOptions.show()
	FormulaFeedbackLabel.hide()

	# Clear previous options
	for c in FormulaOptions.get_children():
		c.queue_free()

	var problem: Variant = _get_current_problem()
	if problem == null:
		push_error("No problem found in _show_formula_choices.")
		return
	if not (problem as Dictionary).has("formula"):
		push_error("Problem has no 'formula' key in _show_formula_choices.")
		return

	# ✅ Get correct + distractors from JSON
	var options: Array = []
	options.append((problem as Dictionary)["formula"])
	if (problem as Dictionary).has("distractors"):
		for d in ((problem as Dictionary)["distractors"] as Array):
			options.append(d)

	# Shuffle all
	options.shuffle()

	# Create buttons
	for formula in options:
		var btn := Button.new()
		btn.text = str(formula)
		btn.pressed.connect(_on_formula_selected.bind(formula))
		FormulaOptions.add_child(btn)

func _on_formula_selected(selected_formula: Variant) -> void:
	var problem: Variant = _get_current_problem()
	if problem == null:
		push_error("No problem found in _on_formula_selected.")
		return
	if not (problem as Dictionary).has("formula"):
		push_error("Problem has no 'formula' key in _on_formula_selected.")
		return
	if str(selected_formula) == str((problem as Dictionary)["formula"]):
		FormulaFeedbackLabel.hide()
		FormulaOptions.hide()
		ProblemLabel.text += "\n\n[b]Correct Formula:[/b] " + str(selected_formula)
		_show_solve_phase()
	else:
		FormulaFeedbackLabel.text = "[color=red]Not quite! Try again.[/color]"
		FormulaFeedbackLabel.show()
		CalculatorButton.hide()

func _show_solve_phase() -> void:
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
	var problem: Variant = _get_current_problem()
	if problem == null:
		push_error("No problem found in _try_submit_solve.")
		return false
	if not (problem as Dictionary).has("answer"):
		push_error("Problem has no 'answer' key in _try_submit_solve.")
		return false
	var user_ans: String = SolveInput.text.strip_edges()
	var correct_ans: float = float((problem as Dictionary)["answer"])
	var user_val: float = 0.0
	if user_ans.is_valid_float():
		user_val = float(user_ans)
	elif user_ans.is_valid_int():
		user_val = float(int(user_ans))
	else:
		# Not a valid number
		return false
	# Accept a small error for floats
	return abs(user_val - correct_ans) < 0.01

func _show_feedback() -> void:
	current_step = Step.FEEDBACK
	var level: Variant = null
	if current_level_index < levels.size():
		level = levels[current_level_index]
	if level == null or not (level as Dictionary).has("problems"):
		NextButton.hide()
		ProblemLabel.text = "[b]All levels complete![/b]"
		return
	var last_problem: bool = false
	if typeof((level as Dictionary)["problems"]) == TYPE_ARRAY:
		var probs: Array = ((level as Dictionary)["problems"] as Array)
		last_problem = current_problem_index >= probs.size() - 1

	if last_problem:
		ProblemLabel.text += "\n\n[b]Level Complete![/b]"
		_on_level_cleared()

		if current_level_index < levels.size() - 1:
			_next_as_next_level()
		else:
			_next_as_back_to_topics()
	else:
		NextButton.text = "Next Problem"
		NextButton.show()
		CalculatorButton.hide()
		_hide_calculator()

func _on_NextButton_pressed() -> void:
	if current_step == Step.SHOW_PROBLEM:
		_show_given_inputs()
	elif current_step == Step.GIVEN:
		if _try_submit_given():
			GivenInputContainer.hide()
			_show_formula_choices()
		else:
			var problem: Variant = _get_current_problem()
			if problem != null and (problem as Dictionary).has("text"):
				ProblemLabel.text = "[color=red]Try again![/color]\n" + str((problem as Dictionary)["text"])
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
		var level: Variant = null
		if current_level_index < levels.size():
			level = levels[current_level_index]
		if level == null or not (level as Dictionary).has("problems"):
			ProblemLabel.text = "[b]All stages complete![/b]"
			NextButton.hide()
			return
		var probs: Array = ((level as Dictionary)["problems"] as Array)
		if current_problem_index < probs.size() - 1:
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
			_go_back_to_topics()
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

func _hide_calculator() -> void:
	if is_instance_valid(calculator_instance):
		calculator_instance.hide()

func _next_as_back_to_topics() -> void:
	current_step = Step.END
	NextButton.text = "Back to Topics"
	NextButton.show()
	CalculatorButton.hide()
	_hide_calculator()

func _next_as_next_level() -> void:
	current_step = Step.END
	NextButton.text = "Next Level"
	NextButton.show()
	CalculatorButton.hide()
	_hide_calculator()


# When a level is cleared, unlock in ProgressManager and notify achievements.
func _on_level_cleared() -> void:
	_report_level_completion_once()
	if progress_key_for_this_level != "":
		ProgressManager.progress[progress_key_for_this_level] = true
		ProgressManager.save_progress()

# Report to Achievement Manager once per level
func _report_level_completion_once() -> void:
	if _level_reported:
		return
	_level_reported = true
	var mgr: Node = get_node_or_null("/root/Achievement_Manager")
	if mgr:
		var level_number: int = current_level_index + 1 # 1-based
		mgr.call("record_level_completion", path_name, level_number)

# Unlock the current level in your ProgressManager (so the next level appears unlocked in menus)
# Unlock the current level in your ProgressManager (so the next level appears unlocked in menus)
func _mark_level_unlocked() -> void:
	if progress_key_for_this_level == "":
		return

	var pm: Variant = null
	# Prefer the autoload global if present, else fallback to node under /root
	if typeof(ProgressManager) != TYPE_NIL:
		pm = ProgressManager
	else:
		pm = get_node_or_null("/root/ProgressManager")

	if pm == null:
		push_warning("ProgressManager not found; cannot unlock '%s'." % progress_key_for_this_level)
		return

	# Read the 'progress' property safely; don't call .has() on the node
	var prog: Variant = pm.get("progress")
	if typeof(prog) != TYPE_DICTIONARY:
		push_warning("ProgressManager.progress is missing or not a Dictionary; cannot unlock '%s'." % progress_key_for_this_level)
		return

	var prog_dict: Dictionary = prog as Dictionary
	prog_dict[progress_key_for_this_level] = true

	# Optional: set back in case your PM relies on setter/notification
	pm.set("progress", prog_dict)

	# Save if available
	if pm.has_method("save_progress"):
		pm.call("save_progress")

# Route back to the correct level select scene per path
func _go_back_to_topics() -> void:
	if back_to_topics_scene != "" and ResourceLoader.exists(back_to_topics_scene):
		get_tree().change_scene_to_file(back_to_topics_scene)
		return
	# Fallback: try to guess by path_name if export not set
	match path_name:
		"geometric":
			get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Geometric_levels/geometric_levels.tscn")
		_:
			get_tree().change_scene_to_file("res://Scene/LearningPortal.tscn/Artithmethic_levels/arithmetic_levels.tscn")
