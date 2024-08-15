extends Node


signal open_save_dialog
signal save_project
signal return_to_main_menu

func _ready():
	pass

func _on_main_menu_save_project():
	print("In save_project.gd start _on_main_menu_save_project()")
	#var t = $SaveDialog.get_theme_font_size("", "")
	#$SaveDialog.add_theme_font_size_override("", 60)
	#print("t: ", t)
	open_save_dialog.emit()
	
	pass # Replace with function body.




func _on_save_dialog_finished_saving():
	return_to_main_menu.emit()
