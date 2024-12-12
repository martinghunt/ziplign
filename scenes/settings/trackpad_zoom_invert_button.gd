extends Button


func _ready():
	set_pressed(Globals.userdata.config.get_value("trackpad", "invert_v", false))
	update_text()

func update_text():
	if button_pressed:
		text = ":"
	else:
		text = ">"

func _pressed():
	Globals.userdata.config.set_value("trackpad", "invert_v", button_pressed)
	update_text()
