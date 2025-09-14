extends Control

# File: res://Scene/Adaptive_Mode/Main.gd
# Purpose: Robust adaptive-problem loader + generator for SeQuest (Godot 4.x)
func sum_arithmetic(a: float, d: float, n: int) -> float:
	return (n / 2.0) * (2 * a + (n - 1) * d)

func sum_geometric(a: float, r: float, n: int) -> float:
	if r == 1:
		return a * n
	return a * (pow(r, n) - 1) / (r - 1)

func nth_arithmetic(a: float, d: float, n: int) -> float:
	return a + (n - 1) * d

func nth_geometric(a: float, r: float, n: int) -> float:
	return a * pow(r, n - 1)

func multiply(a: float, b: float) -> float:
	return a * b

func add(a: float, b: float) -> float:
	return a + b

func subtract(a: float, b: float) -> float:
	return a - b

func divide(a: float, b: float) -> float:
	return a / b

@onready var problem_label: Label = $ProblemLabel
@onready var answer_line: LineEdit = $AnswerLine
@onready var submit_button: Button = $SubmitButton
@onready var rating_container: HBoxContainer = $RatingContainer
@onready var easy_button: Button = $RatingContainer/EasyButton
@onready var medium_button: Button = $RatingContainer/MediumButton
@onready var hard_button: Button = $RatingContainer/HardButton

var problems: Array = []
var current_problem: Dictionary = {}
var difficulty_level: int = 1
var formula_functions = {
	"sum_arithmetic": Callable(self, "sum_arithmetic"),
	"sum_geometric": Callable(self, "sum_geometric"),
	"nth_arithmetic": Callable(self, "nth_arithmetic"),
	"nth_geometric": Callable(self, "nth_geometric"),
	"multiply": Callable(self, "multiply"),
	"add": Callable(self, "add"),
	"subtract": Callable(self, "subtract"),
	"divide": Callable(self, "divide")
}

func _ready() -> void:
	randomize()
	submit_button.pressed.connect(_on_SubmitButton_pressed)
	easy_button.pressed.connect(_on_EasyButton_pressed)
	medium_button.pressed.connect(_on_MediumButton_pressed)
	hard_button.pressed.connect(_on_HardButton_pressed)
	load_problems()
	show_new_problem()

func load_problems() -> void:
	var path: String = "res://Scene/Adaptive_Mode/adaptive_problems.json"
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: %s" % path)
		return

	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not f:
		push_error("Unable to open JSON file: %s" % path)
		return

	var text: String = f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)

	if typeof(parsed) == TYPE_ARRAY:
		problems = parsed
		print("Loaded %d problems" % problems.size())
	else:
		push_error("JSON root should be an array of problems")

func show_new_problem() -> void:
	answer_line.text = ""
	rating_container.visible = false

	if problems.is_empty():
		problem_label.text = "(No problems loaded)"
		push_error("No problems available in JSON")
		return

	var candidates: Array[Dictionary] = []
	for p in problems:
		if p.has("difficulty") and int(p["difficulty"]) == difficulty_level:
			candidates.append(p)

	if candidates.is_empty():
		var closest: int = find_closest_difficulty(difficulty_level)
		for p in problems:
			if p.has("difficulty") and int(p["difficulty"]) == closest:
				candidates.append(p)

	if candidates.is_empty():
		push_error("No candidate problems found")
		return

	var template: Dictionary = candidates[randi() % candidates.size()]
	current_problem = generate_problem(template)

	if not current_problem.has("problem"):
		push_error("Generated problem missing 'problem'")
		problem_label.text = "(Error generating problem)"
		return

	problem_label.text = str(current_problem["problem"])

func generate_problem(template: Dictionary) -> Dictionary:
	var var_defs: Dictionary = template.get("variables", {})
	var problem_text: String = template["problem"]
	var vars_dict: Dictionary = {}

	# Generate random values
	for var_name in var_defs.keys():
		var range_vals: Array = var_defs[var_name]
		var minv: int = int(range_vals[0])
		var maxv: int = int(range_vals[1])
		var value: int = _rand_int(minv, maxv)
		vars_dict[var_name] = value
		problem_text = problem_text.replace("{" + var_name + "}", str(value))

	# Calculate answer using formula_type + args
	var answer_val: float = 0.0
	if template.has("formula_type") and template.has("args"):
		answer_val = calculate_problem(template, vars_dict)

	return {
		"id": template.get("id", ""),
		"difficulty": template.get("difficulty", 1),
		"problem": problem_text,
		"variables": var_defs,
		"vars_dict": vars_dict,   # store the dict for reference
		"answer": answer_val
	}


func _rand_int(minv: int, maxv: int) -> int:
	if minv > maxv:
		var tmp: int = minv
		minv = maxv
		maxv = tmp
	return randi_range(minv, maxv)

func find_closest_difficulty(target: int) -> int:
	var seen: Array[int] = []
	for p in problems:
		if p.has("difficulty"):
			var d: int = int(p["difficulty"])
			if not seen.has(d):
				seen.append(d)
	if seen.size() == 0:
		return 1

	var best: int = seen[0]
	var best_dist: int = abs(best - target)
	for d in seen:
		var dist: int = abs(int(d) - target)
		if dist < best_dist:
			best = d
			best_dist = dist
	return best

func calculate_problem(problem_data: Dictionary, vars: Dictionary) -> float:
	if not problem_data.has("formula_type") or not problem_data.has("args"):
		return 0

	var func_ref = formula_functions.get(problem_data["formula_type"], null)
	if func_ref == null:
		return 0

	var args_list = []
	for arg_name in problem_data["args"]:
		if vars.has(arg_name):
			args_list.append(vars[arg_name])
		else:
			args_list.append(0)

	return func_ref.callv(args_list)


func _floats_equal(a: float, b: float, eps: float = 0.0001) -> bool:
	return abs(a - b) <= eps

func _on_SubmitButton_pressed() -> void:
	if current_problem == null or not current_problem.has("problem"):
		push_error("No generated problem to check")
		return

	var player_text: String = answer_line.text.strip_edges()
	if player_text == "":
		problem_label.text += "\nPlease enter an answer."
		return

	var player_val: float = player_text.to_float()
	var correct_val: float = float(current_problem["answer"])

	if _floats_equal(player_val, correct_val):
		problem_label.text += "\n✅ Correct!"
	else:
		problem_label.text += "\n❌ Wrong. Answer: %s" % str(correct_val)

	rating_container.visible = true

func _on_EasyButton_pressed() -> void:
	adjust_difficulty(-1)
	show_new_problem()

func _on_MediumButton_pressed() -> void:
	adjust_difficulty(0)
	show_new_problem()

func _on_HardButton_pressed() -> void:
	adjust_difficulty(1)
	show_new_problem()

func adjust_difficulty(change: int) -> void:
	difficulty_level = clamp(difficulty_level + change, 1, 4)
	print("Difficulty adjusted to %d" % difficulty_level)





# === Custom math helpers for sequences/series ===
