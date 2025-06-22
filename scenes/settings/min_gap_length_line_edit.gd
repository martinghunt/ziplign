extends LineEdit

var min_gap_length: int


func _ready():
	min_gap_length = Globals.userdata.config.get_value("other", "min_gap_length", 10)
	text = str(min_gap_length)


func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		min_gap_length = int(new_text)
		if min_gap_length < 0:
			min_gap_length = 0
			new_text = "0"
		text = new_text
		Globals.userdata.config.set_value("other", "min_gap_length", min_gap_length)
	else:
		text = str(min_gap_length)


func _on_focus_exited():
	_on_text_submitted(text)
