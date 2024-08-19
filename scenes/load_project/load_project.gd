extends Node

signal open_load_dialog
signal return_to_game
signal return_to_main_menu


func _ready():
	pass


func _on_main_menu_load_project():
	open_load_dialog.emit()


func _on_load_dialog_finished_loading():
	return_to_game.emit()


func _on_load_dialog_cancelled_loading():
	return_to_main_menu.emit()
