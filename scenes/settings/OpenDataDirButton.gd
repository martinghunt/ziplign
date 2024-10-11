extends Button


func _ready():
	pass # Replace with function body.


func _on_pressed():
	OS.shell_show_in_file_manager(OS.get_user_data_dir())
