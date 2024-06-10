extends Control

signal return_to_main_menu

func _ready():
	hide()

func _on_return_button_pressed():
	hide()
	return_to_main_menu.emit()


func _on_main_menu_open_settings():
	show()
