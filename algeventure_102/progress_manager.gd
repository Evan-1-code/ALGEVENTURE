extends Node

var current_level_index: int = 0
var current_level_key: String = ""
var progress = {
	"al_1": false,
	"al_2": false,
	"al_3": false,
	"al_4": false,
	"al_5": false,
	"al_6": false,
	"al_7": false,
	"al_8": false,
	"al_9": false,
	"al_10": false,
	"al_11": false,
	"al_12": false,
	"al_13": false,
	"al_14": false,
	"gl_1": false,
	"gl_2": false,
	"gl_3": false,
	"gl_4": false,
	"gl_5": false,
	"gl_6": false,
	"gl_7": false,
	"gl_8": false,
	"gl_9": false,
	"gl_10": false,
	"gl_11": false,
	"gl_12": false,
	"gl_13": false,
	"gl_14": false,
}

const SAVE_PATH = "user://userdata.save"

func _ready():
	load_progress()

func mark_complete(level_name: String) -> void:
	if progress.has(level_name):
		progress[level_name] = true
		save_progress()

func save_progress() -> void:
	var cf = ConfigFile.new()
	for key in progress.keys():
		cf.set_value("progress", key, progress[key])
	cf.save(SAVE_PATH)

func load_progress() -> void:
	var cf = ConfigFile.new()
	var err = cf.load(SAVE_PATH)
	if err == OK:
		# Load all keys from file, overwrite defaults
		for key in cf.get_section_keys("progress"):
			progress[key] = cf.get_value("progress", key, false)
		# Ensure any new levels (not in save) are set to false
		for key in progress.keys():
			if not cf.has_section_key("progress", key):
				progress[key] = false
