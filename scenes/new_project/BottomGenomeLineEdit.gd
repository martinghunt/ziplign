extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_new_project_update_bottom_genome_filename(new_text):
	text = new_text


func _on_new_project_set_bottom_genome_line_edit_enable(b):
	set_selecting_enabled(b)
