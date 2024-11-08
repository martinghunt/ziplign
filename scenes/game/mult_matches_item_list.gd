extends ItemList


signal selected_a_match

var match_ids = []


func _ready():
	pass 


func set_colors():
	for i in range(item_count):
		if is_selected(i):
			set_item_custom_bg_color(i, Globals.theme.colours["ui"]["general_bg"])
		else:
			set_item_custom_bg_color(i, Globals.theme.colours["ui"]["button_bg"])


func set_matches(new_match_ids):
	deselect_all()
	clear()
	match_ids = new_match_ids
	for i in match_ids:
		add_item(Globals.proj_data.get_match_text(i)) 
		set_item_tooltip_enabled(item_count - 1, false)
	set_colors()


func _on_item_selected(index):
	set_colors()
	selected_a_match.emit(match_ids[index])


func _on_up_button_button_up():
	if is_selected(0):
		pass
	else:
		var selected = get_selected_items()
		if len(selected) == 0:
			selected = [1]
			
		select(selected[0] - 1)
		_on_item_selected(selected[0] - 1)
	set_colors()
	ensure_current_is_visible()


func _on_down_button_button_up():
	if is_selected(len(match_ids) - 1):
		pass
	else:
		var selected = get_selected_items()
		if len(selected) == 0:
			selected = [len(match_ids) - 2]
		select(selected[0] + 1)
		_on_item_selected(selected[0] + 1)
	set_colors()
	ensure_current_is_visible()
