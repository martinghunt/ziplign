extends ItemList


signal selected_a_match
signal selected_an_annotation
signal selected_a_sequence

enum Display_type {MATCHES, ANNOTATION, SEQUENCE}
var item_list = []
var displaying = Display_type.MATCHES


func _ready():
	pass


func set_colors():
	for i in range(item_count):
		if is_selected(i):
			set_item_custom_bg_color(i, Globals.theme.colours["ui"]["general_bg"])
		else:
			set_item_custom_bg_color(i, Globals.theme.colours["ui"]["button_bg"])


func set_item_list(new_data, type_of_data):
	displaying = type_of_data
	deselect_all()
	clear()
	item_list = new_data
	for i in item_list:
		if displaying == Display_type.MATCHES:
			add_item(Globals.proj_data.get_match_text(i)) 
		elif displaying == Display_type.ANNOTATION:
			add_item(Globals.top_or_bottom_str[i[0]] + ": " + i[3])
		elif displaying == Display_type.SEQUENCE:
			var strand = "+"
			if i[3]:
				strand = "-"
			add_item(Globals.top_or_bottom_str[i[0]] + ": " + Globals.proj_data.genome_seqs[i[0]]["contigs"][i[1]]["name"] + " " + str(i[2]) + " " + strand)
		else:
			pass
		set_item_tooltip_enabled(item_count - 1, false)
	set_colors()


func set_matches(match_ids):
	set_item_list(match_ids, Display_type.MATCHES)


func set_annotation(annot_data):
	set_item_list(annot_data, Display_type.ANNOTATION)


func set_sequence(seq_data):
	set_item_list(seq_data, Display_type.SEQUENCE)
	

func _on_item_selected(index):
	set_colors()
	if displaying == Display_type.MATCHES:
		selected_a_match.emit(item_list[index])
	elif displaying == Display_type.ANNOTATION:
		selected_an_annotation.emit(item_list[index])
	elif displaying == Display_type.SEQUENCE:
		selected_a_sequence.emit(item_list[index])
	else:
		pass


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
	if is_selected(len(item_list) - 1):
		pass
	else:
		var selected = get_selected_items()
		if len(selected) == 0:
			selected = [len(item_list) - 2]
		select(selected[0] + 1)
		_on_item_selected(selected[0] + 1)
	set_colors()
	ensure_current_is_visible()
