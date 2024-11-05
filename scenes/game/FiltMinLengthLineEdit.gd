extends LineEdit

signal min_match_length_changed

var min_l = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(min_l)


func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		min_l = int(new_text)
		if min_l < 0:
			min_l = 0
		min_match_length_changed.emit(min_l)
	text = str(min_l)
	release_focus()
