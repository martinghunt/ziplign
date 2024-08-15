extends FileDialog

signal finished_saving

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.


func _on_save_project_open_save_dialog():
	size.x = DisplayServer.window_get_size().x - 20
	size.y = DisplayServer.window_get_size().y - 30
	show()


func _on_file_selected(path):
	print("save file selected: ", path)
	Globals.proj_data.save_as_serialized_file(path)
	hide()
	finished_saving.emit()


func _on_canceled():
	hide()
	finished_saving.emit()
