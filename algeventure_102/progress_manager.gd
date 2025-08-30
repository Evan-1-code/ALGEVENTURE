extends Node

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
}

const SAVE_PATH = "user://progress.save"

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
		for key in progress.keys():
			if cf.has_section_key("progress", key):
				progress[key] = cf.get_value("progress", key, false)
