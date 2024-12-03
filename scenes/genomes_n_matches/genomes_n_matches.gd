extends Node2D

signal hscrollbar_set_top_value
signal hscrollbar_set_bottom_value
signal match_selected
signal match_deselected
signal contig_selected
signal contig_deselected
signal annot_selected
signal annot_deselected
signal multimatch_list_found
signal enable_contig_ops


const Matches = preload("res://lib/genomes_n_matches/genome_matches.gd")
const GenomeClass = preload("res://lib/genomes_n_matches/genome.gd")


var matches
var top_genome
var bottom_genome
var x_zoom = 1
var top_x = 0
var bottom_x = 0
var global_top = 82 + Globals.y_offset_not_paused
var global_bottom = 588 + Globals.y_offset_not_paused
var genome_height = 60
var top_scrollbar_value = 0
var bottom_scrollbar_value = 0
var max_genome_x = 0
var color_rect_z_index = 0
var button_move_dist = 0.5
var saved_views = {}
var contig_selected_is_top = true

var dragging = 0
var dragging_rect = Polygon2D.new()
var y_drag_top_top = 0
var y_drag_top_bottom = 0
var y_drag_bottom_top = 0
var y_drag_bottom_bottom = 0
var max_allowed_zoom = 20
var min_allowed_zoom = 0.0

func set_matches():
	var coords = []
	for d in Globals.proj_data.blast_matches:
		var top_contig_start = top_genome.base_contig_pos[d["qry"]]
		var bottom_contig_start = bottom_genome.base_contig_pos[d["ref"]]
		coords.append([
			top_contig_start[0] + d["qstart"],
			top_contig_start[0] + d["qend"],
			bottom_contig_start[0] + d["rstart"],
			bottom_contig_start[0] + d["rend"],
			d["rev"],
			d["pc"],
		])
	matches = Matches.new(coords)


func _ready():
	x_zoom = 1
	top_x = 0
	bottom_x = 0
	top_scrollbar_value = 0
	bottom_scrollbar_value = 0
	hscrollbar_set_bottom_value.emit(0)
	hscrollbar_set_top_value.emit(0)
	if Globals.proj_data.has_annotation():
		genome_height = 130
	else:
		genome_height = 60
	top_genome = GenomeClass.new("top", global_top, global_top + genome_height)
	bottom_genome = GenomeClass.new("bottom", global_bottom - genome_height, global_bottom)
	add_child(top_genome)
	add_child(bottom_genome)
	set_matches()
	add_child(matches)
	matches.set_top_bottom_coords(global_top + genome_height + 10, global_bottom - genome_height - 10)
	max_genome_x = max(top_genome.last_contig_end, bottom_genome.last_contig_end)
	matches.connect("moved_to_selected_match", _on_moved_to_selected_match)
	matches.connect("match_selected", _on_match_selected)
	matches.connect("match_deselected", _on_match_deselected)
	top_genome.connect("contig_selected", _on_contig_selected)
	top_genome.connect("contig_deselected", _on_contig_deselected)
	bottom_genome.connect("contig_selected", _on_contig_selected)
	bottom_genome.connect("contig_deselected", _on_contig_deselected)
	top_genome.connect("annot_selected", _on_annot_selected)
	top_genome.connect("annot_deselected", _on_annot_deselected)
	bottom_genome.connect("annot_selected", _on_annot_selected)
	bottom_genome.connect("annot_deselected", _on_annot_deselected)
	top_genome.connect("move_to_pos", _on_genome_move_to_pos)
	bottom_genome.connect("move_to_pos", _on_genome_move_to_pos)
	$"../../../../ColorRect/ProcessingLabel".position.y = 0.5 * (global_top + global_bottom) - 20 - Globals.y_offset_not_paused
	$"../../../../ColorRect/ProcessingLabel".position.x = Globals.controls_width + 10
	y_drag_top_top = top_genome.tracks_y["coords_top"] - 13
	y_drag_top_bottom = top_genome.bottom + 5
	y_drag_bottom_top = bottom_genome.top - 5
	y_drag_bottom_bottom = bottom_genome.tracks_y["coords_bottom"] + 12
	if dragging_rect.get_parent() == null:
		add_child(dragging_rect)
	dragging_rect.hide()
	dragging_rect.color = Globals.theme.colours["ui"]["text"]
	dragging_rect.color.a = 0.3
	dragging_rect.polygon = [
		Vector2(0, 0),
		Vector2(0, 0),
		Vector2(0, 0),
		Vector2(0, 0),
	]
	dragging_rect.z_index = 10
	min_allowed_zoom = max(get_default_x_zoom() / 2, 0.00011)
	_on_button_zoom_reset_pressed()
	

func get_default_x_zoom():
	return Globals.genomes_viewport_width / (1.05 * max_genome_x)


func set_x_zoom(zoom, centre=null):
	if x_zoom == zoom:
		return
	
	if zoom <= min_allowed_zoom:
		x_zoom = min_allowed_zoom
	elif zoom >= max_allowed_zoom:
		x_zoom = max_allowed_zoom
	else:
		x_zoom = zoom

	top_genome.set_x_zoom(x_zoom, centre)
	bottom_genome.set_x_zoom(x_zoom, centre)
	matches.set_x_zoom(x_zoom, centre)
	top_x = top_genome.x_left - Globals.controls_width
	top_scrollbar_value = 100 * (1 - top_x) /  (x_zoom * top_genome.last_contig_end)
	hscrollbar_set_top_value.emit(top_scrollbar_value)
	bottom_x = bottom_genome.x_left - Globals.controls_width
	bottom_scrollbar_value = 100 * (1 - bottom_x) /  (x_zoom * bottom_genome.last_contig_end)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)


func _on_right_top_scrollbar_value_changed(value):
	top_scrollbar_value = value
	top_x = 1 - x_zoom * value * top_genome.last_contig_end / 100
	top_genome.set_x_left(top_x)
	matches.set_top_x_left(top_x)


func _on_right_bottom_scrollbar_value_changed(value):
	bottom_scrollbar_value = value
	bottom_x = 1 - x_zoom * value * bottom_genome.last_contig_end / 100
	bottom_genome.set_x_left(bottom_x)
	matches.set_bottom_x_left(bottom_x)


func _on_button_zoom_reset_pressed():
	matches.deselect()
	match_deselected.emit()
	set_x_zoom(get_default_x_zoom())
	top_genome.set_x_left(1)
	bottom_genome.set_x_left(1)
	matches.set_top_x_left(1)
	matches.set_bottom_x_left(1)
	hscrollbar_set_top_value.emit(0)
	hscrollbar_set_bottom_value.emit(0)
	top_scrollbar_value = 0
	bottom_scrollbar_value = 0
	top_genome.update_annot_visiblity_recalc_all(x_zoom)
	bottom_genome.update_annot_visiblity_recalc_all(x_zoom)



func _on_button_zoom_minus_pressed(multiplier = 1, centre=null):
	if x_zoom <= min_allowed_zoom:
		pass
	elif x_zoom <= 0.0011:
		set_x_zoom(x_zoom - multiplier * 0.0001, centre)
	elif x_zoom <= 0.011:
		set_x_zoom(x_zoom - multiplier * 0.001, centre)
	elif x_zoom <= 0.11:
		set_x_zoom(x_zoom - multiplier * 0.01, centre)
	elif x_zoom <= 1:
		set_x_zoom(x_zoom - multiplier * 0.1, centre)
	else:
		set_x_zoom(x_zoom - multiplier * 1, centre)


func _on_button_zoom_plus_pressed(multiplier = 1, centre=null):
	if x_zoom >= max_allowed_zoom:
		pass
	elif x_zoom >= 1:
		set_x_zoom(x_zoom + multiplier * 1, centre)
	elif x_zoom >= 0.1:
		set_x_zoom(x_zoom + multiplier * 0.1, centre)
	elif x_zoom >= 0.01:
		set_x_zoom(x_zoom + multiplier * 0.01, centre)
	elif x_zoom >= 0.001:
		set_x_zoom(x_zoom + multiplier * 0.001, centre)
	else:
		set_x_zoom(x_zoom + multiplier * 0.0001, centre)

	
func _on_button_zoom_bp_pressed():
	set_x_zoom(1.01 * Globals.zoom_to_show_bp)

func _on_moved_to_selected_match(selected_id):
	var s = matches.matches[selected_id]
	var x_top = - 0.5 * Globals.genomes_viewport_width + min(s.start1, s.end1) * x_zoom
	var x_bottom = - 0.5 * Globals.genomes_viewport_width + x_zoom * s.start2
	top_genome.set_x_left(-x_top)
	bottom_genome.set_x_left(-x_bottom)
	matches.set_x_lefts(-x_top, -x_bottom)
	var x = 100 *  (x_top - 1) / (x_zoom * top_genome.last_contig_end)
	hscrollbar_set_top_value.emit(x)
	top_scrollbar_value = x
	x = 100 * (x_bottom - 1) / (x_zoom * bottom_genome.last_contig_end)
	hscrollbar_set_bottom_value.emit(x)
	bottom_scrollbar_value = x


func _on_match_selected(selected_id):
	top_genome.deselect_contig()
	bottom_genome.deselect_contig()
	enable_contig_ops.emit(false)
	match_selected.emit(selected_id)
	

func _on_match_deselected():
	match_deselected.emit()


func _on_contig_selected(top_or_bottom):
	if top_or_bottom == "top":
		bottom_genome.deselect_contig()
		contig_selected.emit(top_or_bottom, top_genome.name_of_selected_contig())
		contig_selected_is_top = true
	else:
		top_genome.deselect_contig()
		contig_selected.emit(top_or_bottom, bottom_genome.name_of_selected_contig())
		contig_selected_is_top = false
	enable_contig_ops.emit(true)


func _on_contig_deselected():
	contig_deselected.emit()
	enable_contig_ops.emit(false)


func _on_annot_selected(top_or_bottom, contig_id, annot_id):
	enable_contig_ops.emit(false)
	var contig_name 
	var annot
	if top_or_bottom == "top":
		contig_name = top_genome.contig_names[contig_id]
		annot = top_genome.contigs[contig_name].annot_polys[annot_id].selected_str()
	else:
		contig_name = bottom_genome.contig_names[contig_id]
		annot = bottom_genome.contigs[contig_name].annot_polys[annot_id].selected_str()
	annot_selected.emit(top_or_bottom, contig_name, annot_id, annot)

func _on_annot_deselected(top_or_bottom, contig_id, annot_id):
	var contig_name 
	if top_or_bottom == "top":
		contig_name = top_genome.contig_names[contig_id]
	else:
		contig_name = bottom_genome.contig_names[contig_id]
	annot_deselected.emit(top_or_bottom, contig_name, annot_id)


func _on_game_new_project_go():
	top_genome.clear_all()
	bottom_genome.clear_all()
	matches.clear_all()
	remove_child(top_genome)
	remove_child(bottom_genome)
	remove_child(matches)
	_ready()


func shift_top(x_shift):
	if x_shift == 0:
		return
	top_scrollbar_value += x_shift
	_on_right_top_scrollbar_value_changed(top_scrollbar_value)
	hscrollbar_set_top_value.emit(top_scrollbar_value)


func shift_bottom(x_shift):
	if x_shift == 0:
		return
	bottom_scrollbar_value += x_shift
	_on_right_bottom_scrollbar_value_changed(bottom_scrollbar_value)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)


func move_top_and_bottom(top_frac, bottom_frac):
	var d = 80 * get_viewport().get_visible_rect().size.x / x_zoom
	if top_frac != 0:
		shift_top(d * top_frac / top_genome.last_contig_end)
	if bottom_frac != 0:
		shift_bottom(d * bottom_frac / bottom_genome.last_contig_end)


func start_processing_overlay():
	Globals.paused = true
	color_rect_z_index = $"../../../../ColorRect".z_index
	$"../../../../ColorRect".z_index = 2000
	$"../../../../ColorRect".color.a = 0.5
	$"../../../../ColorRect/ProcessingLabel".show()
	get_tree().set_pause(true)


func stop_processing_overlay():
	$"../../../../ColorRect".color.a = 1
	$"../../../../ColorRect".z_index = color_rect_z_index
	$"../../../../ColorRect/ProcessingLabel".hide()
	await get_tree().create_timer(0.1).timeout
	Globals.paused = false
	get_tree().set_pause(false)


func move_selected_contig(to_i):
	start_processing_overlay()
	await get_tree().create_timer(0.1).timeout
	save_view(10)
	
	if contig_selected_is_top:
		await Globals.proj_data.move_contig("top", top_genome.selected_contig, to_i)
	else:
		await Globals.proj_data.move_contig("bottom", bottom_genome.selected_contig, to_i)
	
	_on_game_new_project_go()
	load_view(10)
	
	if contig_selected_is_top:
		top_genome.select_contig(to_i)
	else:
		bottom_genome.select_contig(to_i)
		
	stop_processing_overlay()


func reverse_complement(to_rev, contig_id=null):
	start_processing_overlay()
	await get_tree().create_timer(0.1).timeout
	
	if contig_id == null:
		Globals.proj_data.reverse_complement_genome(to_rev)
	else:
		Globals.proj_data.reverse_complement_one_contig(to_rev, contig_id)
		save_view(10) # cannot be used by the user
		_on_game_new_project_go()
		load_view(10)
		stop_processing_overlay()
		return
	
	top_genome.deselect_contig()
	bottom_genome.deselect_contig()
	var currently_selected = matches.selected
	var current_zoom = x_zoom
	_on_game_new_project_go()
	set_x_zoom(current_zoom)

	if currently_selected != -1:
		matches.selected = currently_selected
		matches.matches[matches.selected].select()
		matches.move_to_selected()
		_on_match_selected(currently_selected)
	
	stop_processing_overlay()
	


func _on_button_fine_toggle_toggled(toggled_on):
	if toggled_on:
		button_move_dist = 0.02
	else:
		button_move_dist = 0.5


func _on_button_move_left_none_pressed():
	move_top_and_bottom(-button_move_dist, 0)


func _on_button_move_right_none_pressed():
	move_top_and_bottom(button_move_dist, 0)


func _on_button_move_left_left_pressed():
	move_top_and_bottom(-button_move_dist, -button_move_dist)
	

func _on_button_move_left_right_pressed():
	move_top_and_bottom(0.5 * button_move_dist, -0.5 * button_move_dist)


func _on_button_move_right_left_pressed():
	move_top_and_bottom(-0.5 * button_move_dist, 0.5 * button_move_dist)


func _on_button_move_right_right_pressed():
	move_top_and_bottom(button_move_dist, button_move_dist)


func _on_button_move_none_left_pressed():
	move_top_and_bottom(0, -button_move_dist)


func _on_button_move_none_right_pressed():
	move_top_and_bottom(0, button_move_dist)


func _on_game_window_resized():
	matches.update_hide_and_show()
	top_genome.reset_contig_coords(-1, -1, true)
	bottom_genome.reset_contig_coords(-1, -1, true)
	$"../../ColorRect".size.x = get_viewport().get_visible_rect().size.x + 10

func _on_revcomp_top_button_pressed():
	reverse_complement("top")


func _on_revcomp_bottom_button_pressed():
	reverse_complement("bottom")


func _on_filt_min_length_line_edit_min_match_length_changed(value):
	Globals.match_min_show_length = value
	matches.update_hide_and_show()


func _on_filt_min_identity_line_edit_min_match_pc_id_changed(value):
	Globals.match_min_show_pc_id = value
	matches.update_hide_and_show()


func save_view(i):
	saved_views[i] = {
		"zoom": x_zoom,
		"top_scrollbar": top_scrollbar_value,
		"bottom_scrollbar": bottom_scrollbar_value,
	}


func load_view(i):
	set_x_zoom(saved_views[i]["zoom"])
	_on_right_top_scrollbar_value_changed(saved_views[i]["top_scrollbar"])
	hscrollbar_set_top_value.emit(saved_views[i]["top_scrollbar"])
	_on_right_bottom_scrollbar_value_changed(saved_views[i]["bottom_scrollbar"])
	hscrollbar_set_bottom_value.emit(saved_views[i]["bottom_scrollbar"])


func y_drag_in_genome(y):
	var actual_y = y + Globals.y_offset_not_paused
	if y_drag_top_top <= actual_y and actual_y <= y_drag_top_bottom:
		return 1
	elif y_drag_bottom_top <= actual_y and actual_y <= y_drag_bottom_bottom:
		return 2
	else:
		return 0
		

func event_is_wheel_up(event):
	return (event.button_index == MOUSE_BUTTON_WHEEL_UP and not Globals.userdata.config.get_value("mouse", "invert_wheel")) \
		or (event.button_index == MOUSE_BUTTON_WHEEL_DOWN and Globals.userdata.config.get_value("mouse", "invert_wheel"))

func event_is_wheel_down(event):
	return (event.button_index == MOUSE_BUTTON_WHEEL_DOWN and not Globals.userdata.config.get_value("mouse", "invert_wheel")) \
		or (event.button_index == MOUSE_BUTTON_WHEEL_UP and Globals.userdata.config.get_value("mouse", "invert_wheel"))


func _unhandled_input(event):
	if Globals.paused:
		return
	
	if event is InputEventKey:
		for i in range(1, 10):
			if event.is_action_released("view_" + str(i)):
				if event.is_shift_pressed():
					save_view(i)
				elif i in saved_views:
					load_view(i)
	elif event is InputEventMouseButton and event.position.x > Globals.controls_width - 13 and event_is_wheel_down(event):
		await _on_button_zoom_minus_pressed(Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.2, event.position.x - Globals.controls_width)
	elif event is InputEventMouseButton and event.position.x > Globals.controls_width - 13 and event_is_wheel_up(event):
		await _on_button_zoom_plus_pressed(Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.2, event.position.x - Globals.controls_width)
	elif event is InputEventPanGesture and event.position.x > Globals.controls_width - 13:
		if Globals.userdata.config.get_value("trackpad", "v_sens") > 0 and event.delta.x == 0:
			if Globals.userdata.config.get_value("trackpad", "invert_v"):
				event.delta.y *= -1
			if event.delta.y > 0:
				await _on_button_zoom_minus_pressed(event.delta.y * Globals.userdata.config.get_value("trackpad", "v_sens"), event.position.x - Globals.controls_width)
			elif event.delta.y < 0:
				await _on_button_zoom_plus_pressed(-event.delta.y * Globals.userdata.config.get_value("trackpad", "v_sens"), event.position.x - Globals.controls_width)
		elif Globals.userdata.config.get_value("trackpad", "h_sens") > 0 and event.delta.y == 0:
			await move_top_and_bottom(Globals.userdata.config.get_value("trackpad", "h_sens") * event.delta.x, Globals.userdata.config.get_value("trackpad", "h_sens") * event.delta.x)
	elif event is InputEventMagnifyGesture and event.position.x > Globals.controls_width - 13:
		if event.factor > 1:
			await _on_button_zoom_plus_pressed(0.2 * Globals.userdata.config.get_value("trackpad", "p_sens") * event.factor, event.position.x - Globals.controls_width)
		else:
			await _on_button_zoom_minus_pressed(0.2 * Globals.userdata.config.get_value("trackpad", "p_sens") * (2 - event.factor), event.position.x - Globals.controls_width)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var drag_start = event.position
			dragging = y_drag_in_genome(drag_start.y)
			if dragging == 0:
				return

			dragging_rect.polygon[0].x = drag_start.x - 50 - 2 * Globals.controls_width
			for i in [1, 2, 3]:
				dragging_rect.polygon[i].x = dragging_rect.polygon[0].x
			
			if dragging == 1:
				dragging_rect.polygon[0].y = y_drag_top_top - Globals.y_offset_not_paused
				dragging_rect.polygon[2].y = y_drag_top_bottom - Globals.y_offset_not_paused
			elif dragging == 2:
				dragging_rect.polygon[0].y = y_drag_bottom_top - Globals.y_offset_not_paused
				dragging_rect.polygon[2].y = y_drag_bottom_bottom - Globals.y_offset_not_paused
			dragging_rect.polygon[1].y = dragging_rect.polygon[0].y
			dragging_rect.polygon[3].y = dragging_rect.polygon[2].y
			dragging_rect.show()
		elif dragging > 0:
			dragging_rect.hide()
			var start = dragging_rect.polygon[0].x + 50 + 2 * Globals.controls_width
			var end = dragging_rect.polygon[1].x + 50 + 2 * Globals.controls_width
			# You'd expect start != end here, but doing it this way makes it
			# easier to select a contig
			if abs(start - end) > 1:
				var match_ids = matches.get_matches_in_range(min(start, end), max(start, end), dragging==1)
				top_genome.deselect_contig()
				bottom_genome.deselect_contig()
				top_genome.deselect_all_annot()
				bottom_genome.deselect_all_annot()
				contig_deselected.emit()
				enable_contig_ops.emit(false)
				if len(match_ids) > 0:
					multimatch_list_found.emit(match_ids)
			dragging = 0

			queue_redraw()
	elif event is InputEventMouseMotion and dragging:
		queue_redraw()

func _draw():
	if dragging > 0:
		var end = get_global_mouse_position()
		end.x -= 50 + 2 * Globals.controls_width
		dragging_rect.polygon[1].x = end.x
		dragging_rect.polygon[2].x = end.x


func _on_mult_matches_item_list_selected_a_match(i):
	matches.set_selected_match(i)
	match_selected.emit(i)
	matches.move_to_selected()


func name_of_selected_contig():
	if contig_selected_is_top:
		return top_genome.name_of_selected_contig()
	else:
		return bottom_genome.name_of_selected_contig()


func _on_rev_button_pressed():
	if contig_selected_is_top:
		var selected_contig_id = top_genome.selected_contig
		await reverse_complement("top", name_of_selected_contig())
		top_genome.select_contig(selected_contig_id)
	else:
		var selected_contig_id = bottom_genome.selected_contig
		await reverse_complement("bottom", name_of_selected_contig())
		bottom_genome.select_contig(selected_contig_id)


func number_of_contigs_in_selected_contig_genome():
	if contig_selected_is_top:
		return top_genome.number_of_contigs()
	else:
		return bottom_genome.number_of_contigs()


func get_selected_contig_id():
	if contig_selected_is_top:
		return top_genome.selected_contig
	else:
		return bottom_genome.selected_contig



func _on_move_start_button_pressed():
	var selected_contig_id = get_selected_contig_id()
	if selected_contig_id == 0:
		return
	move_selected_contig(0)


func _on_move_left_button_pressed():
	var selected_contig_id = get_selected_contig_id()
	if selected_contig_id == 0:
		return
	move_selected_contig(selected_contig_id - 1)


func _on_move_right_button_pressed():
	var selected_contig_id = get_selected_contig_id()
	var number_of_contigs = number_of_contigs_in_selected_contig_genome()
	if selected_contig_id >= number_of_contigs - 1:
		return
	move_selected_contig(selected_contig_id + 1)


func _on_move_end_button_pressed():
	var selected_contig_id = get_selected_contig_id()
	var number_of_contigs = number_of_contigs_in_selected_contig_genome()
	if selected_contig_id >= number_of_contigs - 1:
		return
	move_selected_contig(number_of_contigs - 1)


func _on_genome_move_to_pos(top_or_bottom, mouse_x):
	var window_size = get_viewport().get_visible_rect().size
	var game_width = window_size.x - Globals.controls_width
	var middle = Globals.controls_width + 0.5 * game_width
	var to_move = (mouse_x - middle) / game_width
	if top_or_bottom == "top":
		move_top_and_bottom(to_move, 0)
	else:
		move_top_and_bottom(0, to_move)
