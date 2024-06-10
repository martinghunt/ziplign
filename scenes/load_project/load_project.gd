extends Control


var dirname = ""
signal update_dir_line_edit
signal go_load_new_project
signal cancel_load_project


func _ready():
	hide()
	get_viewport().files_dropped.connect(on_files_dropped)


func on_files_dropped(files):
	print("Got files: ", files)
	if len(files) != 1:
		return
	dirname = files[0]
	update_dir_line_edit.emit(dirname)


func _on_load_button_pressed():
	hide()
	Globals.proj_data.init_from_dir(dirname)
	go_load_new_project.emit()
	

func _on_main_menu_load_project():
	show()


func _on_cancel_button_pressed():
	hide()
	dirname = ""
	update_dir_line_edit.emit(dirname)
	cancel_load_project.emit()
