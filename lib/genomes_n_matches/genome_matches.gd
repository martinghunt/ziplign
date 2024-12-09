extends Node

class_name GenomeMatches

const MatchClass = preload("match.gd")

signal moved_to_selected_match
signal match_selected
signal match_deselected

var matches = []
var hover_matches = []
var selected = -1
var top = 100
var bottom = 600
var x_left_bottom = 0
var x_left_top = 0
var visible_matches = 0
var previous_zoom = 1.0


func _init():
	previous_zoom = Globals.x_zoom


func add_match(hit_id, start1, end1, start2, end2):
	matches.append(MatchClass.new(hit_id, start1, end1, start2, end2))


func number_of_matches():
	return len(matches)


func update_hide_and_show():
	var total_visible = 0
	for m in matches:
		m.update_canvas_coords()
		if total_visible > Globals.max_matches_on_screen:
			m.make_invisible()
		else:
			m.update_visibility()
			if m.is_currently_visible:
				total_visible += 1


func update_after_x_zoom_change(centre=null):
	if centre == null:
		centre = 0.5 * (Globals.genomes_viewport_width)
	x_left_bottom = centre - Globals.x_zoom * (centre - x_left_bottom) / previous_zoom
	x_left_top = centre - Globals.x_zoom * (centre - x_left_top) / previous_zoom
	update_hide_and_show()
	previous_zoom = Globals.x_zoom


func set_top_x_left(x):
	x_left_top = x
	update_hide_and_show()
	

func set_bottom_x_left(x):
	x_left_bottom = x
	update_hide_and_show()


func set_x_lefts(new_x_left_top, new_x_left_bottom):
	x_left_top = new_x_left_top
	x_left_bottom = new_x_left_bottom
	update_hide_and_show()


func move_to_selected():
	if selected == -1:
		return -1

	moved_to_selected_match.emit(selected)
	return selected


func get_matches_in_range(start, end, is_top):
	var found = []
	for m in matches:
		if m.is_currently_visible and m.intersects_range(start, end, is_top):
			found.append(m.blast_id)
	return found


func _ready():
	for m in matches:
		add_child(m)
		m.connect("mouse_in", on_mouse_in_match)
		m.connect("mouse_out", on_mouse_out_match)


func clear_all():
	for m in matches:
		remove_child(m)
		m.free()
	matches.clear()


func deselect():
	if selected != -1:
		matches[selected].deselect()
		selected = -1
		match_deselected.emit()


func set_selected_match(match_id):
	deselect()
	matches[match_id].select()
	selected = match_id
	match_selected.emit(match_id)


func _unhandled_input(event):
	if Globals.paused:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if len(hover_matches) >= 1:
					var match_id = hover_matches[-1]
					if selected != -1 and selected == match_id and event.is_double_click():
						moved_to_selected_match.emit(selected)
						return
					matches[selected].deselect()
					matches[match_id].select()
					match_selected.emit(match_id)
					selected = match_id
				elif len(hover_matches) == 0 and selected != -1:
					matches[selected].deselect()
					match_deselected.emit()
					selected = -1
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if selected in hover_matches:
					matches[selected].deselect()
					match_deselected.emit()
					selected = -1


func on_mouse_in_match(match_id):
	if match_id not in hover_matches:
		hover_matches.append(match_id)


func on_mouse_out_match(match_id):
	hover_matches.erase(match_id)
