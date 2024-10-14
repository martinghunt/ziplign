extends Node2D

signal start_init


func set_children_font(node):
	for x in node.get_children():
		x.add_theme_color_override("font_color", Globals.theme.colours["ui"]["text"])

func reset_colours():
	# Getting one stylebox and changing it should affect all of them
	var sb = $MainMenu/MainContainer/MainVBoxContainer/ResumeButton.get_theme_stylebox("normal")
	sb.bg_color = Globals.theme.colours["ui"]["button_bg"]

	sb = $LoadProject/LoadDialog.get_theme_stylebox("panel")
	sb.bg_color = Globals.theme.colours["ui"]["general_bg"]
		
	sb = $SaveProject/SaveDialog.get_theme_stylebox("panel")
	sb.bg_color = Globals.theme.colours["ui"]["general_bg"]

	$BoxContainer/ColorRect.color = Globals.theme.colours["ui"]["general_bg"]
	

	
	var ui_text_to_set = [
		$MainMenu/StatusRichTextLabel,
		$Init/StatusRichTextLabel,
		
	]
	for x in ui_text_to_set:
		x.add_theme_color_override("default_color", Globals.theme.colours["ui"]["text"])

	var children_to_set = [
		$MainMenu/MainContainer/MainVBoxContainer,
		$NewProject/MainVBoxContainer/CancelOrGoContainer,
		$NewProject/MainVBoxContainer/StatusGenomeContainer,
		$NewProject/MainVBoxContainer/TopGenomeContainer,
		$NewProject/MainVBoxContainer/BottomGenomeContainer,
		$NewProject/MainVBoxContainer/CompareContainer,
	]
	for x in children_to_set:
		set_children_font(x)
	


func _ready():
	reset_colours()
	start_init.emit()


func _on_settings_theme_updated():
	reset_colours()
	
