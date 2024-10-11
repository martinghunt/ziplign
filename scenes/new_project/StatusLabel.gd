extends Label

var default_text = "Add top genome: drag-n-drop or put filename in the box"


func reset_text():
	text = default_text

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_text()


func _on_new_project_set_status_text(t):
	text = t


func _on_new_project_reset_status_text():
	reset_text()
