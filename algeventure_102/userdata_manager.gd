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
