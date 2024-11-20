extends Label

var default_text = ""


func reset_text():
	text = default_text

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_text()


func _on_new_project_set_status_text(t):
	text = t
