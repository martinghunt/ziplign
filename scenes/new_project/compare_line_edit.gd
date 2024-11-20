extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = Globals.userdata.default_blast_options


func _on_text_submitted(new_text):
	text = new_text
	Globals.userdata.blast_options = new_text


func _on_focus_exited():
	Globals.userdata.blast_options = text


func _on_new_project_reset_compare_line_edit():
	_on_text_submitted(Globals.userdata.default_blast_options)
