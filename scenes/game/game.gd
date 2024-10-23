extends Control

signal pause
signal new_project_go
signal window_resized
#signal reload


func _ready():
	hide()
	get_tree().get_root().size_changed.connect(resize)
	set_colours()
	resize()
	$"../BoxContainer/ColorRect".z_index = 100
	Globals.paused = true

func set_colours():
	$"../BoxContainer/ColorRect".color = Globals.theme.colours["genomes_bg"]

func resize():
	var window_size = get_viewport().get_visible_rect().size
	$MainHBoxContainer/BoxContainer/VBoxContainer2/RightTopScrollbar.size.x = window_size.x - Globals.controls_width
	$MainHBoxContainer/BoxContainer/VBoxContainer2/RightBottomScrollbar.size.x = window_size.x - Globals.controls_width
	$MainHBoxContainer/BoxContainer/VBoxContainer2.size.x = window_size.x - Globals.controls_width
	Globals.genomes_viewport_width = window_size.x - Globals.controls_width
	window_resized.emit()


func _on_pause_button_pressed():
	hide()
	$"../BoxContainer/ColorRect".z_index = 100
	Globals.paused = true
	pause.emit()


func resume():
	$"../BoxContainer/ColorRect".z_index = 0
	Globals.paused = false
	show()

func _on_main_menu_resume():
	resume()


func _on_new_project_new_project_go_button():
	new_project_go.emit()
	resume()


func _on_load_project_go_load_new_project():
	new_project_go.emit()
	resume()


func _on_main_menu_reload():
	new_project_go.emit()
	set_colours()
	resume()
