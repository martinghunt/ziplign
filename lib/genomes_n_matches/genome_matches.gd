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
var x_zoom = 1
var x_left_bottom = 0
var x_left_top = 0

func _init(coords):
	for c in coords:
		matches.append(MatchClass.new(len(matches), c[0], c[1], c[2], c[3], c[4], c[5]))
	update_hide_and_show()
	

func update_hide_and_show():
	for m in matches:
		m.update_visibility()


func set_x_zoom(new_x_zoom):
	x_zoom = new_x_zoom
	for m in matches:
		m.set_x_zoom(x_zoom)


func set_top_x_left(x):
	x_left_top = x
	for m in matches:
		m.set_top_x_left(x_left_top)

func set_bottom_x_left(x):
	x_left_bottom = x
	for m in matches:
		m.set_bottom_x_left(x_left_bottom)


func set_x_lefts(new_x_left_top, new_x_left_bottom):
	x_left_top = new_x_left_top
	x_left_bottom = new_x_left_bottom
	for m in matches:
		m.set_x_lefts(x_left_top, x_left_bottom)


func move_to_selected():
	if selected == -1:
		return -1

	set_top_x_left(-matches[selected].x_left_start1)
	set_bottom_x_left(-matches[selected].x_left_start2)
	moved_to_selected_match.emit(selected)
	return selected


func set_top_bottom_coords(y_top, y_bottom):
	for m in matches:
		m.set_top_bottom_coords(y_top, y_bottom)


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
		


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed or event.double_click:
				if len(hover_matches) >= 1:
					var match_id = hover_matches[-1]
					if selected != -1 and selected == match_id:
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
