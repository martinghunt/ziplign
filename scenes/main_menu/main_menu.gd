extends Control

signal resume
signal new_project
signal load_project
signal save_project
signal open_settings
var quit_selected = false


func _on_resume_button_pressed():
	hide()
	resume.emit()


func _on_new_button_pressed():
	hide()
	new_project.emit()


func _on_load_button_pressed():
	hide()
	load_project.emit()


func _on_save_button_pressed():
	hide()
	save_project.emit()
	
	
func _on_game_pause():
	show()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_new_project_new_project_cancel():
	show()


#func _on_load_project_cancel_load_project():
#	show()


func _on_settings_return_to_main_menu():
	show()


func _on_settings_button_pressed():
	hide()
	open_settings.emit()


func _on_save_project_return_to_main_menu():
	show()


func _on_load_project_return_to_game():
	hide()
	resume.emit()


func _on_load_project_return_to_main_menu():
	show()
