extends Control

signal return_to_main_menu
signal theme_updated

func _ready():
	hide()

func _on_return_button_pressed():
	Globals.userdata.save_config()
	hide()
	return_to_main_menu.emit()


func _on_main_menu_open_settings():
	$VBoxContainer/GridContainer/ThemeOptionButton.set_selected_to_match_theme()
	$VBoxContainer/GridContainer/MouseWheelSensLineEdit._ready()
	$VBoxContainer/GridContainer/TrackpadZoomSensLineEdit._ready()
	$VBoxContainer/GridContainer/TrackpadLRSensLineEdit._ready()
	show()

func _on_theme_option_button_theme_updated():
	theme_updated.emit()
