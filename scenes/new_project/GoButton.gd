extends Button

func _ready():
	set_disabled(true)


func _on_new_project_enable_go_button(x):
	set_disabled(not x)
