extends Button

func _ready() -> void:
	text = "Back"
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Back button pressed!")  # test
	print("History:", SceneManager.history)  # show what's stored
	SceneManager.go_back()
