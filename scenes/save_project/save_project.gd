extends Node

signal open_save_dialog
signal save_project
signal return_to_main_menu


func _ready():
	pass


func _on_main_menu_save_project():
	open_save_dialog.emit()


func _on_save_dialog_finished_saving():
	return_to_main_menu.emit()
