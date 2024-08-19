extends FileDialog

signal finished_saving


func _ready():
	hide()


func _on_save_project_open_save_dialog():
	#size.x = DisplayServer.window_get_size().x - 20
	#size.y = DisplayServer.window_get_size().y - 30
	#var window_size = get_viewport().get_visible_rect().size
	#print("in _on_save_project_open_save_dialog(). window_size:", window_size)
	#print("DisplayServer.window_get_size():", DisplayServer.window_get_size())
	set_current_dir(Globals.userdata.home_dir)
	show()


func _on_file_selected(path):
	Globals.proj_data.save_as_serialized_file(path)
	hide()
	finished_saving.emit()


func _on_canceled():
	hide()
	finished_saving.emit()
