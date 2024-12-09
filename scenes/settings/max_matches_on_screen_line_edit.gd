extends LineEdit

signal max_matches_updated
var maxOnScreen: int


func _ready():
	maxOnScreen = Globals.userdata.config.get_value("other", "max_matches_on_screen", 500)
	text = str(maxOnScreen)

func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		maxOnScreen = int(new_text)
		if maxOnScreen < 0:
			maxOnScreen = 0
			new_text = "0"
		text = new_text
		Globals.userdata.config.set_value("other", "max_matches_on_screen", maxOnScreen)
		max_matches_updated.emit()
	else:
		text = str(maxOnScreen)


func _on_focus_exited():
	_on_text_submitted(text)
