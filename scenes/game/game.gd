extends Control

signal pause
signal new_project_go
signal window_resized


func _ready():
	hide()
	get_tree().get_root().size_changed.connect(resize)
	resize()


func resize():
	var window_size = get_viewport().get_visible_rect().size
	$MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer/RightTopScrollbar.size.x = window_size.x - Globals.controls_width
	$MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer/RightBottomScrollbar.size.x = window_size.x - Globals.controls_width
	$MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer.size.x = window_size.x - Globals.controls_width
	$MainHBoxContainer/RightViewportContainer/RightViewport.size.x = window_size.x - Globals.controls_width
	Globals.genomes_viewport_width = window_size.x
	window_resized.emit()


func _on_pause_button_pressed():
	hide()
	pause.emit()


func _on_main_menu_resume():
	show()


func _on_new_project_new_project_go_button():
	new_project_go.emit()
	show()


func _on_load_project_go_load_new_project():
	new_project_go.emit()
	show()
