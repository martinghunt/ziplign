extends LineEdit

signal max_match_length_changed

var max_l = Globals.match_max_show_length

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(max_l)


func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		max_l = int(new_text)
		if max_l < 0:
			max_l = 0
		max_match_length_changed.emit(max_l)
	text = str(max_l)
	release_focus()


func _on_focus_exited():
	_on_text_submitted(text)
