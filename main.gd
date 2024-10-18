extends Node2D

signal start_init


func set_font_color(node):
	node.add_theme_color_override("font_color", Globals.theme.colours["ui"]["text"])
	node.add_theme_color_override("font_hover_color", Globals.theme.colours["ui"]["text_hover"])
	node.add_theme_color_override("font_focus_color", Globals.theme.colours["ui"]["text"])


func set_children_font(node):
	for x in node.get_children():
		set_font_color(x)


func set_filedialog_colors(dialog):
	dialog.get_theme_stylebox("panel").bg_color = Globals.theme.colours["ui"]["general_bg"]
	set_children_font(dialog.get_vbox())
	set_font_color(dialog.get_cancel_button())
	set_font_color(dialog.get_ok_button())
	set_font_color(dialog.get_label())
	set_font_color(dialog.get_line_edit())
	dialog.add_theme_color_override("file_icon_color", Globals.theme.colours["ui"]["text"])
	dialog.add_theme_color_override("folder_icon_color", Globals.theme.colours["ui"]["text"])
	var children = dialog.get_vbox().get_children()
	var top_hbox_children = children[0].get_children()

	# the buttons that are just icons. Make them all text colour
	for i in [0, 1, 2, 6, 7]:
		top_hbox_children[i].modulate = Globals.theme.colours["ui"]["text"]
		
	for x in dialog.get_vbox().get_children():
		set_children_font(x)
	
	var tree = children[2].get_children()[0]
	tree.add_theme_color_override("guide_color", Globals.theme.colours["ui"]["text"]) 
	tree.get_theme_stylebox("panel").bg_color = Globals.theme.colours["ui"]["button_bg"]


func reset_colours():
	# Get an arbitrary button. Changing the styleboxes for it affects all buttons
	var b = $MainMenu/MainContainer/MainVBoxContainer/ResumeButton
	b.get_theme_stylebox("normal").bg_color = Globals.theme.colours["ui"]["button_bg"]
	b.get_theme_stylebox("hover").bg_color = Globals.theme.colours["ui"]["button_highlight"]

	set_filedialog_colors($LoadProject/LoadDialog)
	set_filedialog_colors($SaveProject/SaveDialog)

	$BoxContainer/ColorRect.color = Globals.theme.colours["ui"]["general_bg"]
	$Game/ColorRect.color = Globals.theme.colours["ui"]["general_bg"]
	$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/ColorRect.color = Globals.theme.colours["ui"]["panel_bg"]
	$Game/MainHBoxContainer/RightViewportContainer/RightViewport/BoxContainer/ColorRect.color = Globals.theme.colours["ui"]["general_bg"]
	
	var ui_text_to_set = [
		$MainMenu/StatusRichTextLabel,
		$Init/StatusRichTextLabel,
		$Game/MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer/HBoxContainer/TopCoordsText,
		$NewProject/MainVBoxContainer/InfoRichTextLabel,
	]
	for x in ui_text_to_set:
		x.add_theme_color_override("default_color", Globals.theme.colours["ui"]["text"])

	var children_to_set = [
		$MainMenu/MainContainer/MainVBoxContainer,
		$NewProject/MainVBoxContainer/CancelOrGoContainer,
		$NewProject/MainVBoxContainer/TestDataContainer,
		$NewProject/MainVBoxContainer/StatusGenomeContainer,
		$NewProject/MainVBoxContainer/TopGenomeContainer,
		$NewProject/MainVBoxContainer/BottomGenomeContainer,
		$NewProject/MainVBoxContainer/CompareContainer,
		$Settings/CenterContainer/VBoxContainer,
		$Settings/CenterContainer/VBoxContainer/ThemeVBoxContainer,
		$Settings/CenterContainer/VBoxContainer/OpenDataDirContainer,
		$Game/MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer/HBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/NavigationVBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/NavigationVBoxContainer/BoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/VBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/VBoxContainer/ZoomHBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/FilterVBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/RevcompVBoxContainer,
		$Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/RevcompVBoxContainer/RecvompHBoxContainer,
	]
	for x in children_to_set:
		set_children_font(x)
	
	# Change stylebox for one scrollbar, so all others also change
	var sbar = $Game/MainHBoxContainer/RightViewportContainer/RightViewport/VBoxContainer/RightTopScrollbar
	sbar.get_theme_stylebox("scroll").bg_color = Globals.theme.colours["ui"]["button_bg"]
	sbar.get_theme_stylebox("grabber").bg_color = Globals.theme.colours["ui"]["text"]
	sbar.get_theme_stylebox("grabber_highlight").bg_color = Globals.theme.colours["ui"]["button_highlight"]
	sbar.get_theme_stylebox("grabber_pressed").bg_color = Globals.theme.colours["ui"]["button_pressed"]
	
	var optb = $Settings/CenterContainer/VBoxContainer/ThemeVBoxContainer/ThemeOptionButton
	optb.get_theme_stylebox("normal").bg_color = Globals.theme.colours["ui"]["button_bg"]
	optb.get_theme_stylebox("hover").bg_color = Globals.theme.colours["ui"]["button_highlight"]
	set_font_color(optb)
	var popup = optb.get_popup()
	popup.get_theme_stylebox("panel").bg_color = Globals.theme.colours["ui"]["button_bg"]
	popup.get_theme_stylebox("hover").bg_color = Globals.theme.colours["ui"]["button_highlight"]
	set_font_color(popup)
	popup.add_theme_font_size_override("font_size", 30)
	
	var ledit = $Game/MainHBoxContainer/LeftViewportContainer/LeftViewport/VBoxContainer/FilterVBoxContainer/FiltMinLengthLineEdit
	ledit.get_theme_stylebox("normal").bg_color = Globals.theme.colours["ui"]["button_bg"]
	
	
func _ready():
	reset_colours()
	start_init.emit()


func _on_settings_theme_updated():
	reset_colours()
	
