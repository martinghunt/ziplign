extends FileDialog


signal finished_loading
signal cancelled_loading


func _ready():
	hide()


func _on_load_project_open_load_dialog():
	set_current_dir(Globals.userdata.home_dir)
	show()


func _on_file_selected(path):
	Globals.proj_data.init_from_dir(path)
	hide()
	finished_loading.emit()


func _on_canceled():
	hide()
	cancelled_loading.emit()
