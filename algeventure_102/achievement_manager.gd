extends Node
# Note: Do NOT declare class_name here if this script is autoloaded as "AchievementManager"

signal achievement_unlocked(id: String, name: String, description: String, category: String)

const SAVE_PATH := "user://achievements.cfg"

const CATEGORY_PROGRESSION := "Progression"
const CATEGORY_MODE_MASTERY := "Mode Mastery"
const CATEGORY_PERFORMANCE := "Performance"
const CATEGORY_SECRET := "Secret"

# Help the type checker by annotating the const as Dictionary
const ACHIEVEMENTS: Dictionary = {
	"first_steps": {
		"name": "First Steps",
		"description": "Complete your first level in either Arithmetic or Geometric.",
		"category": CATEGORY_PROGRESSION
	},
	"arithmetic_adept": {
		"name": "Arithmetic Adept",
		"description": "Reach Level 7 in Arithmetic.",
		"category": CATEGORY_PROGRESSION
	},
	"arithmetic_master": {
		"name": "Arithmetic Master",
		"description": "Complete all 14 Arithmetic levels.",
		"category": CATEGORY_PROGRESSION
	},
	"geometric_adept": {
		"name": "Geometric Adept",
		"description": "Reach Level 7 in Geometric.",
		"category": CATEGORY_PROGRESSION
	},
	"geometric_master": {
		"name": "Geometric Master",
		"description": "Complete all 14 Geometric levels.",
		"category": CATEGORY_PROGRESSION
	},
	"adaptive_explorer": {
		"name": "Adaptive Explorer",
		"description": "Finish 10 adaptive problems in one session.",
		"category": CATEGORY_MODE_MASTERY
	},
	"difficulty_tamer": {
		"name": "Difficulty Tamer",
		"description": "Rate a problem as “Very Hard” and still solve it correctly.",
		"category": CATEGORY_MODE_MASTERY
	},
	"flawless_streak": {
		"name": "Flawless Streak",
		"description": "Solve 5 problems in a row without errors (any mode).",
		"category": CATEGORY_PERFORMANCE
	},
	"perfect_pair": {
		"name": "The Perfect Pair",
		"description": "Finish both Arithmetic and Geometric full clears on the same day.",
		"category": CATEGORY_SECRET
	}
}

# Persistent progress
var unlocked: Dictionary = {} # id -> {"unlocked_at": int}
var arithmetic_levels_completed: Dictionary = {} # level_index:int -> true
var geometric_levels_completed: Dictionary = {} # level_index:int -> true

# Session-scoped
var streak_current: int = 0
var session_adaptive_count: int = 0
var session_solved_very_hard: bool = false

const TOTAL_ARITH_LEVELS := 14
const TOTAL_GEOM_LEVELS := 14

func _ready() -> void:
	_load_progress()

func start_session() -> void:
	streak_current = 0
	session_adaptive_count = 0
	session_solved_very_hard = false

func end_session() -> void:
	pass

func record_level_completion(path: String, level_index: int) -> void:
	if path == "arithmetic":
		arithmetic_levels_completed[level_index] = true
	elif path == "geometric":
		geometric_levels_completed[level_index] = true
	else:
		push_warning("AchievementManager.record_level_completion: Unknown path '%s'." % path)
		return

	_check_progression_achievements()
	_save_progress()

func record_adaptive_problem_result(correct: bool, player_rating: String, finished: bool = true) -> void:
	if finished:
		session_adaptive_count += 1

	if correct:
		streak_current += 1
	else:
		streak_current = 0

	if correct and player_rating.strip_edges().to_lower() in ["very hard", "very_hard", "veryhard"]:
		session_solved_very_hard = true

	_check_adaptive_achievements()
	_check_streak_achievements()
	_save_progress()

func is_unlocked(id: String) -> bool:
	return unlocked.has(id)

func get_unlocked_data() -> Dictionary:
	return unlocked.duplicate()

func get_all_achievements() -> Dictionary:
	return ACHIEVEMENTS

func get_progress_snapshot() -> Dictionary:
	return {
		"arithmetic_completed_count": arithmetic_levels_completed.size(),
		"geometric_completed_count": geometric_levels_completed.size(),
		"streak_current": streak_current,
		"session_adaptive_count": session_adaptive_count
	}

# --- Internal checks ---

func _check_progression_achievements() -> void:
	var arith_count := arithmetic_levels_completed.size()
	var geom_count := geometric_levels_completed.size()

	if (arith_count + geom_count) >= 1:
		_unlock("first_steps")

	if arith_count >= 7:
		_unlock("arithmetic_adept")

	if arith_count >= TOTAL_ARITH_LEVELS:
		var just_unlocked := _unlock("arithmetic_master")
		if just_unlocked:
			_maybe_unlock_perfect_pair()

	if geom_count >= 7:
		_unlock("geometric_adept")

	if geom_count >= TOTAL_GEOM_LEVELS:
		var just_unlocked_g := _unlock("geometric_master")
		if just_unlocked_g:
			_maybe_unlock_perfect_pair()

func _check_adaptive_achievements() -> void:
	if session_adaptive_count >= 10:
		_unlock("adaptive_explorer")

	if session_solved_very_hard:
		_unlock("difficulty_tamer")

func _check_streak_achievements() -> void:
	if streak_current >= 5:
		_unlock("flawless_streak")

func _maybe_unlock_perfect_pair() -> void:
	if not (unlocked.has("arithmetic_master") and unlocked.has("geometric_master")):
		return
	var ts_a: int = unlocked["arithmetic_master"]["unlocked_at"]
	var ts_g: int = unlocked["geometric_master"]["unlocked_at"]
	if _same_day(ts_a, ts_g):
		_unlock("perfect_pair")

func _unlock(id: String) -> bool:
	if not ACHIEVEMENTS.has(id):
		push_warning("AchievementManager: Unknown achievement id '%s'." % id)
		return false
	if unlocked.has(id):
		return false

	var now_ts := Time.get_unix_time_from_system()
	unlocked[id] = {"unlocked_at": now_ts}

	# Ensure the type checker is happy: cast the dict and use get() with defaults.
	var meta := (ACHIEVEMENTS.get(id, {}) as Dictionary)
	var title := String(meta.get("name", ""))
	var desc := String(meta.get("description", ""))
	var cat := String(meta.get("category", ""))
	emit_signal("achievement_unlocked", id, title, desc, cat)
	return true

# --- Save/Load ---

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "arithmetic_levels_completed", arithmetic_levels_completed.keys())
	cfg.set_value("progress", "geometric_levels_completed", geometric_levels_completed.keys())

	for id in ACHIEVEMENTS.keys():
		if unlocked.has(id):
			cfg.set_value("achievements", id, int(unlocked[id]["unlocked_at"]))

	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("AchievementManager: Failed to save progress to %s (err %d)" % [SAVE_PATH, err])

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return

	arithmetic_levels_completed.clear()
	geometric_levels_completed.clear()

	var arith_list: Array = cfg.get_value("progress", "arithmetic_levels_completed", [])
	for i in arith_list:
		arithmetic_levels_completed[int(i)] = true

	var geom_list: Array = cfg.get_value("progress", "geometric_levels_completed", [])
	for i in geom_list:
		geometric_levels_completed[int(i)] = true

	unlocked.clear()
	for id in ACHIEVEMENTS.keys():
		if cfg.has_section_key("achievements", id):
			var ts: int = int(cfg.get_value("achievements", id, 0))
			if ts > 0:
				unlocked[id] = {"unlocked_at": ts}



func unlock(ach_key: String):
	var timestamp = Time.get_datetime_string_from_system() # Or however you set it
	UserDataManager.unlock_achievement(ach_key, timestamp)
# --- Utils ---


func _same_day(ts1: int, ts2: int) -> bool:
	var a := Time.get_datetime_dict_from_unix_time(ts1)
	var b := Time.get_datetime_dict_from_unix_time(ts2)
	return a.year == b.year and a.month == b.month and a.day == b.day
