extends Node

const SAVE_PATH = "user://userdata.save"
var data = {
	"progress": {},        # Level unlocks (al_1, gl_2, etc.)
	"achievements": {},    # Achievements unlocked
}

func _ready():
	load_data()

func save_data():
	var cf = ConfigFile.new()
	for section in data.keys():
		for key in data[section].keys():
			cf.set_value(section, key, data[section][key])
	cf.save(SAVE_PATH)

func load_data():
	var cf = ConfigFile.new()
	var err = cf.load(SAVE_PATH)
	if err == OK:
		for section in data.keys():
			for key in data[section].keys():
				if cf.has_section_key(section, key):
					data[section][key] = cf.get_value(section, key, data[section][key])
	else:
		save_data()

func mark_level_complete(level_key: String):
	data["progress"][level_key] = true
	save_data()

func reset_progress():
	for i in range(1, 15):
		var key = "al_%d" % i
		data["progress"][key] = (i == 1)  # Only al_1 unlocked
	for i in range(1, 15):
		var key = "gl_%d" % i
		data["progress"][key] = false
	save_data()


# UserDataManager: Tracks and saves player performance for SeQuest
# To use, set this script as an Autoload singleton named 'UserDataManager' in Project Settings > Autoload.

# -- Tracked Variables --
var problems_solved: int = 0
var correct_answers: int = 0
var wrong_answers: int = 0
var used_hints: int = 0
var start_time: int = 0
var end_time: int = 0
var total_time: int = 0
var mode: String = ""
var player_id: String = ""
var accuracy: float = 0.0

# -- Session Control --

# Starts a new session, resets stats, records start time and sets player/mode.
func start_session(player_id_: String, mode_: String) -> void:
	# Reset all tracked variables
	problems_solved = 0
	correct_answers = 0
	wrong_answers = 0
	used_hints = 0
	start_time = Time.get_unix_time_from_system()
	end_time = 0
	total_time = 0
	accuracy = 0.0
	player_id = player_id_
	mode = mode_

# Records an answer attempt; increments correct or wrong count.
func record_answer(is_correct: bool) -> void:
	problems_solved += 1
	if is_correct:
		correct_answers += 1
	else:
		wrong_answers += 1

# Records a hint usage during session.
func record_hint_use() -> void:
	used_hints += 1

# Ends session, calculates total_time and accuracy.
func end_session() -> void:
	end_time = Time.get_unix_time_from_system()
	total_time = end_time - start_time
	accuracy = (float(correct_answers) / float(problems_solved)) * 100.0 if problems_solved > 0 else 0.0

# Saves the session data as JSON in user:// with timestamped filename.
func save_data_to_file() -> void:
	var date_str := Time.get_datetime_string_from_system() # e.g., "2025-10-05T12:43:00"
	var save_dict := {
		"player_id": player_id,
		"mode": mode,
		"problems_solved": problems_solved,
		"correct_answers": correct_answers,
		"wrong_answers": wrong_answers,
		"accuracy": accuracy,
		"used_hints": used_hints,
		"total_time": total_time,
		"date": date_str
	}
	var json_text := JSON.stringify(save_dict, "\t") # pretty print for readability
	var fname := "user://session_%s_%s.json" % [player_id, date_str]
	var file := FileAccess.open(fname, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
	else:
		push_warning("UserDataManager: Could not save file %s" % fname)

# -- Future: Add CSV export or analytics methods here --

# Example usage in another scene:
#
#   UserDataManager.start_session("P01", "progressive")
#   UserDataManager.record_answer(true)   # Correct answer
#   UserDataManager.record_answer(false)  # Wrong answer
#   UserDataManager.record_hint_use()
#   UserDataManager.end_session()
#   UserDataManager.save_data_to_file()
#
# This will save a file like: user://session_P01_2025-10-05T12:43:00.json
