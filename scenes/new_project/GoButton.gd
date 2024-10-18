extends Button

func _ready():
	set_disabled(true)


func _on_new_project_enable_go_button(x):
	set_disabled(not x)


func _on_use_test_data_button_pressed():
	set_disabled(false)
