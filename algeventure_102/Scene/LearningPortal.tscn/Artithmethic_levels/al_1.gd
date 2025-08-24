extends Node

@export var JSON_PATH: String = "res://Scene/LearningPortal.tscn/ARlevel_problems/ALevel_1_problem.json"

var problems: Array = []
var current_problem_idx: int = 0
var current_step: int = 0
var state: String = "show_problem" # States: show_problem, show_given, ask_formula, formula_correct, solve_steps, solved

@onready var DisplayLabel = $DisplayLabel
@onready var FormulaOptions = $FormulaOptions
@onready var ActionButton = $ActionButton
@onready var FeedbackLabel = $FeedbackLabel
@onready var HintButton = $HintButton
@onready var HintLabel = $HintLabel

func _ready():
	load_problems()
	show_problem()
	ActionButton.pressed.connect(_on_ActionButton_pressed)
	HintButton.pressed.connect(_on_HintButton_pressed)

func load_problems():
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		var json = JSON.parse_string(data)
		if typeof(json) == TYPE_DICTIONARY and "problems" in json:
			problems = json["problems"]
		else:
			push_error("JSON root does not contain 'problems' array!")
	else:
		push_error("Could not open problems JSON file!")

func show_problem():
	state = "show_problem"
	current_step = 0
	FormulaOptions.hide()
	FeedbackLabel.text = ""
	HintLabel.text = ""
	var p = problems[current_problem_idx]
	DisplayLabel.text = p["problem"]
	ActionButton.text = "Next"
	ActionButton.show()

func show_given():
	state = "show_given"
	var p = problems[current_problem_idx]
	DisplayLabel.text = "[b]Given:[/b]\n" + "\n".join(p["given"])
	ActionButton.text = "What formula should we use?"

func ask_formula():
	state = "ask_formula"
	FormulaOptions.show()
	# Clear previous buttons
	for child in FormulaOptions.get_children():
		child.queue_free()
	var p = problems[current_problem_idx]
	for i in p["formula_options"].size():
		var b = Button.new()
		b.text = p["formula_options"][i]
		b.pressed.connect(_on_formula_pressed.bind(i))
		FormulaOptions.add_child(b)
	DisplayLabel.text = "Which formula should be used?"
	ActionButton.hide()

func solve_steps():
	state = "solve_steps"
	FormulaOptions.hide()
	var p = problems[current_problem_idx]
	current_step = 0
	DisplayLabel.text = p["solution_steps"][current_step]
	ActionButton.text = "Next Step"
	ActionButton.show()

func complete_problem():
	state = "solved"
	DisplayLabel.text = "✅ Correct! Problem Solved."
	if current_problem_idx < problems.size() - 1:
		ActionButton.text = "Next Problem"
	else:
		ActionButton.text = "Back to Level Select"
	ActionButton.show()

func _on_ActionButton_pressed():
	match state:
		"show_problem":
			show_given()
		"show_given":
			ask_formula()
		"formula_correct":
			solve_steps()
		"solve_steps":
			var p = problems[current_problem_idx]
			current_step += 1
			if current_step < p["solution_steps"].size():
				DisplayLabel.text = p["solution_steps"][current_step]
			else:
				complete_problem()
		"solved":
			if current_problem_idx < problems.size() - 1:
				current_problem_idx += 1
				show_problem()
			else:
				# Return to level select logic here
				get_tree().change_scene_to_file("res://LevelSelect.tscn") # Example

func _on_formula_pressed(idx):
	var p = problems[current_problem_idx]
	var selected = p["formula_options"][idx]
	if selected == p["correct_formula"]:
		FeedbackLabel.text = ""
		ActionButton.text = "Now Solve"
		ActionButton.show()
		state = "formula_correct"
	else:
		FeedbackLabel.text = "[color=red]Not quite, try again.[/color]"

func _on_HintButton_pressed():
	var p = problems[current_problem_idx]
	if "hints" in p and p["hints"].size() > 0:
		HintLabel.text = "[b]Hint:[/b] " + "\n".join(p["hints"])
	else:
		HintLabel.text = "No hints available."
