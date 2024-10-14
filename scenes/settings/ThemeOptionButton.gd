extends OptionButton

signal theme_updated

var names = Globals.theme.theme_names()

func _ready():
	for i in range(names.size()):
		add_item(names[i], i)
		if names[i] == Globals.theme.name:
			selected = i


func _on_item_selected(index):
	if names[index] != Globals.theme.name:
		Globals.theme.set_theme(names[index])
		Globals.reload_needed = true
		theme_updated.emit()
