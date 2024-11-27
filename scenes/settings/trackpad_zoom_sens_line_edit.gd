extends LineEdit


var sens


func _ready():
	sens = Globals.userdata.config.get_value("trackpad", "v_sens", 1.0)
	text = str(sens)

func _on_text_submitted(new_text):
	if new_text.is_valid_float():
		sens = float(new_text)
		if sens < 0:
			sens = 0
			new_text = "0"
		text = new_text
		Globals.userdata.config.set_value("trackpad", "v_sens", sens)
	else:
		text = str(sens)


func _on_focus_exited():
	_on_text_submitted(text)
