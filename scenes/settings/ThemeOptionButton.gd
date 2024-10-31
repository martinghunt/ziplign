extends OptionButton

signal theme_updated

var names = Globals.theme.theme_names()

func _ready():
	for i in range(names.size()):
		add_item(names[i], i)
		if names[i] == Globals.theme.name:
			selected = i

func set_selected_to_match_theme():
	for i in range(names.size()):
		if names[i] == Globals.theme.name:
			selected = i
			break

func _on_item_selected(index):
	if names[index] != Globals.theme.name:
		Globals.theme.set_theme(names[index])
		Globals.reload_needed = true
		theme_updated.emit()
		Globals.userdata.config.set_value("colours", "theme", names[index])
		Globals.userdata.save_config()
