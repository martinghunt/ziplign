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
signal annotation_list_found
signal sequence_list_found
signal sequence_range_selected
signal drag_range_selected
signal enable_contig_ops


const Matches = preload("res://lib/genomes_n_matches/genome_matches.gd")
const GenomeClass = preload("res://lib/genomes_n_matches/genome.gd")


var matches
var top_genome
var bottom_genome
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
var selected_seq_range_start = []
var selected_seq_range_end = []


func set_matches():
	matches = Matches.new()
	for h in Globals.proj_data.blast_hits:
		var top_contig_start = top_genome.base_contig_pos[h.qry_id]
		var bottom_contig_start = bottom_genome.base_contig_pos[h.ref_id]
		matches.add_match(matches.number_of_matches(), 
			top_contig_start[0] + h.qstart, 
			top_contig_start[0] + h.qend,
			bottom_contig_start[0] + h.rstart,
			bottom_contig_start[0] + h.rend,
		)


func _ready():
	Globals.x_zoom = 1
	Globals.top_x_left = 0
	Globals.bottom_x_left = 0
	if Globals.proj_data.has_annotation():
		genome_height = 130
	else:
		genome_height = 60
	top_genome = GenomeClass.new(Globals.TOP, global_top, global_top + genome_height)
	bottom_genome = GenomeClass.new(Globals.BOTTOM, global_bottom - genome_height, global_bottom)
	add_child(top_genome)
	add_child(bottom_genome)
	Globals.matches_y_top = global_top + genome_height + 10
	Globals.matches_y_bottom = global_bottom - genome_height - 10
	set_matches()
	add_child(matches)

	#matches.set_top_bottom_coords(global_top + genome_height + 10, global_bottom - genome_height - 10)
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
	if Globals.x_zoom == zoom:
		return
	
	if zoom <= min_allowed_zoom:
		Globals.x_zoom = min_allowed_zoom
	elif zoom >= max_allowed_zoom:
		Globals.x_zoom = max_allowed_zoom
	else:
		Globals.x_zoom = zoom

	top_genome.set_x_zoom(Globals.x_zoom, centre)
	bottom_genome.set_x_zoom(Globals.x_zoom, centre)
	Globals.top_x_left = top_genome.x_left - Globals.controls_width
	Globals.bottom_x_left = bottom_genome.x_left - Globals.controls_width
	matches.update_after_x_zoom_change(centre)
	top_scrollbar_value = 100 * (1 - Globals.top_x_left) /  (Globals.x_zoom * top_genome.last_contig_end)
	hscrollbar_set_top_value.emit(top_scrollbar_value)
	bottom_scrollbar_value = 100 * (1 - Globals.bottom_x_left) /  (Globals.x_zoom * bottom_genome.last_contig_end)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)


func _on_right_top_scrollbar_value_changed(value, update_matches=true):
	top_scrollbar_value = value
	Globals.top_x_left = 1 - Globals.x_zoom * value * top_genome.last_contig_end / 100
	top_genome.set_x_left(Globals.top_x_left)
	if update_matches:
		matches.set_top_x_left(Globals.top_x_left)


func _on_right_bottom_scrollbar_value_changed(value, update_matches=true):
	bottom_scrollbar_value = value
	Globals.bottom_x_left = 1 - Globals.x_zoom * value * bottom_genome.last_contig_end / 100
	bottom_genome.set_x_left(Globals.bottom_x_left)
	if update_matches:
		matches.set_bottom_x_left(Globals.bottom_x_left)


func _on_button_zoom_reset_pressed():
	matches.deselect()
	match_deselected.emit()
	top_genome.set_x_left(1)
	bottom_genome.set_x_left(1)
	matches.set_top_x_left(1)
	matches.set_bottom_x_left(1)
	set_x_zoom(get_default_x_zoom())
	set_top_scrollbar_value(0)
	set_bottom_scrollbar_value(0)
	top_genome.update_annot_visiblity_recalc_all(Globals.x_zoom)
	bottom_genome.update_annot_visiblity_recalc_all(Globals.x_zoom)
	matches.update_hide_and_show()



func _on_button_zoom_minus_pressed(multiplier = 1, centre=null):
	if Globals.x_zoom <= min_allowed_zoom:
		Globals.x_zoom = min_allowed_zoom
	elif Globals.x_zoom <= 0.0011:
		set_x_zoom(Globals.x_zoom - multiplier * 0.0001, centre)
	elif Globals.x_zoom <= 0.011:
		set_x_zoom(Globals.x_zoom - multiplier * 0.001, centre)
	elif Globals.x_zoom <= 0.11:
		set_x_zoom(Globals.x_zoom - multiplier * 0.01, centre)
	elif Globals.x_zoom <= 1:
		set_x_zoom(Globals.x_zoom - multiplier * 0.1, centre)
	else:
		set_x_zoom(Globals.x_zoom - multiplier * 1, centre)


func _on_button_zoom_plus_pressed(multiplier = 1, centre=null):
	if Globals.x_zoom >= max_allowed_zoom:
		Globals.x_zoom = max_allowed_zoom
	elif Globals.x_zoom >= 1:
		set_x_zoom(Globals.x_zoom + multiplier * 1, centre)
	elif Globals.x_zoom >= 0.1:
		set_x_zoom(Globals.x_zoom + multiplier * 0.1, centre)
	elif Globals.x_zoom >= 0.01:
		set_x_zoom(Globals.x_zoom + multiplier * 0.01, centre)
	elif Globals.x_zoom >= 0.001:
		set_x_zoom(Globals.x_zoom + multiplier * 0.001, centre)
	else:
		set_x_zoom(Globals.x_zoom + multiplier * 0.0001, centre)

	
func _on_button_zoom_bp_pressed():
	set_x_zoom(1.01 * Globals.zoom_to_show_bp)


func _on_moved_to_selected_match(selected_id):
	var s = matches.matches[selected_id]
	Globals.top_x_left = 0.5 * Globals.genomes_viewport_width - min(s.start1, s.end1) * Globals.x_zoom
	Globals.bottom_x_left = 0.5 * Globals.genomes_viewport_width - Globals.x_zoom * s.start2
	top_genome.set_x_left(Globals.top_x_left)
	bottom_genome.set_x_left(Globals.bottom_x_left)
	matches.set_x_lefts(Globals.top_x_left, Globals.bottom_x_left)
	var x = 100 *  (1 - Globals.top_x_left) / (Globals.x_zoom * top_genome.last_contig_end)
	hscrollbar_set_top_value.emit(x)
	top_scrollbar_value = x
	x = 100 * (1 - Globals.bottom_x_left) / (Globals.x_zoom * bottom_genome.last_contig_end)
	hscrollbar_set_bottom_value.emit(x)
	bottom_scrollbar_value = x


func _on_match_selected(selected_id):
	clear_sequence_highlights()
	top_genome.deselect_contig()
	bottom_genome.deselect_contig()
	enable_contig_ops.emit(false)
	match_selected.emit(selected_id)
	

func _on_match_deselected():
	match_deselected.emit()


func _on_contig_selected(top_or_bottom):
	clear_sequence_highlights()
	if top_or_bottom == Globals.TOP:
		bottom_genome.deselect_contig()
		contig_selected.emit(top_or_bottom, top_genome.selected_contig)
		contig_selected_is_top = true
	else:
		top_genome.deselect_contig()
		contig_selected.emit(top_or_bottom, bottom_genome.selected_contig)
		contig_selected_is_top = false
	enable_contig_ops.emit(true)


func _on_contig_deselected():
	contig_deselected.emit()
	enable_contig_ops.emit(false)


func _on_annot_selected(top_or_bottom, contig_id, annot_id):
	clear_sequence_highlights()
	enable_contig_ops.emit(false)
	var contig_name 
	var annot
	if top_or_bottom == Globals.TOP:
		contig_name = top_genome.contig_name(contig_id)
		annot = top_genome.contigs[contig_id].annot_polys[annot_id].selected_str()
	else:
		contig_name = bottom_genome.contig_name(contig_id)
		annot = bottom_genome.contigs[contig_id].annot_polys[annot_id].selected_str()
	annot_selected.emit(top_or_bottom, contig_name, annot_id, annot)
	

func _on_annot_deselected(top_or_bottom, contig_id, annot_id):
	var contig_name 
	if top_or_bottom == Globals.TOP:
		contig_name = top_genome.contig_name(contig_id)
	else:
		contig_name = bottom_genome.contig_name(contig_id)
	annot_deselected.emit(top_or_bottom, contig_name, annot_id)


func _on_game_new_project_go():
	top_genome.clear_all()
	bottom_genome.clear_all()
	matches.clear_all()
	remove_child(top_genome)
	remove_child(bottom_genome)
	remove_child(matches)
	$"../../../VBoxContainer/MultMatchesVBoxContainer".hide()
	_ready()


func set_top_scrollbar_value(new_value, centre=false):
	if new_value == top_scrollbar_value:
		return
	top_scrollbar_value = new_value
	_on_right_top_scrollbar_value_changed(top_scrollbar_value)
	hscrollbar_set_top_value.emit(top_scrollbar_value)
	if centre:
		move_top_and_bottom(-0.5, 0)


func set_bottom_scrollbar_value(new_value, centre=false):
	if new_value == bottom_scrollbar_value:
		return
	bottom_scrollbar_value = new_value
	_on_right_bottom_scrollbar_value_changed(bottom_scrollbar_value)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)
	if centre:
		move_top_and_bottom(0, -0.5)


func shift_top(x_shift, update_matches=true):
	if x_shift == 0:
		return
	top_scrollbar_value += x_shift
	_on_right_top_scrollbar_value_changed(top_scrollbar_value, update_matches)
	hscrollbar_set_top_value.emit(top_scrollbar_value)


func shift_bottom(x_shift, update_matches=true):
	if x_shift == 0:
		return
	bottom_scrollbar_value += x_shift
	_on_right_bottom_scrollbar_value_changed(bottom_scrollbar_value, update_matches)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)


func move_top_and_bottom(top_frac, bottom_frac):
	var d = 80 * get_viewport().get_visible_rect().size.x / Globals.x_zoom
	if top_frac != 0:
		shift_top(d * top_frac / top_genome.last_contig_end, bottom_frac==0)
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


func move_selected_contig(move_type):
	start_processing_overlay()
	await get_tree().create_timer(0.1).timeout
	save_view(10)
	var selected_contig_id
	
	if contig_selected_is_top:
		selected_contig_id = top_genome.selected_contig
		await Globals.proj_data.move_contig(Globals.TOP, top_genome.selected_contig, move_type)
	else:
		selected_contig_id = bottom_genome.selected_contig
		await Globals.proj_data.move_contig(Globals.BOTTOM, bottom_genome.selected_contig, move_type)
	

	_on_game_new_project_go()
	load_view(10)
	
	if contig_selected_is_top:
		top_genome.select_contig(selected_contig_id)
	else:
		bottom_genome.select_contig(selected_contig_id)
		
	stop_processing_overlay()


func reverse_complement(to_rev, contig_id=null):
	await get_tree().create_timer(0.1).timeout
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
	var current_zoom = Globals.x_zoom
	_on_game_new_project_go()
	set_x_zoom(current_zoom)

	if currently_selected != -1:
		matches.selected = currently_selected
		matches.matches[matches.selected].select()
		matches.move_to_selected()
		_on_match_selected(currently_selected)
	await get_tree().create_timer(0.1).timeout
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
	reverse_complement(Globals.TOP)


func _on_revcomp_bottom_button_pressed():
	reverse_complement(Globals.BOTTOM)


func _on_filt_min_length_line_edit_min_match_length_changed(value):
	Globals.match_min_show_length = value
	matches.update_hide_and_show()
	
func _on_filt_max_length_line_edit_max_match_length_changed(value):
	Globals.match_max_show_length = value
	matches.update_hide_and_show()

func _on_filt_min_identity_line_edit_min_match_pc_id_changed(value):
	Globals.match_min_show_pc_id = value
	matches.update_hide_and_show()


func save_view(i):
	saved_views[i] = {
		"zoom": Globals.x_zoom,
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


func genome_ranges_to_clipboard(top_or_bottom, range_start, range_end):
	print("genome_ranges_to_clipboard start", top_or_bottom, ", ", range_start, ", ", range_end)
	
	DisplayServer.clipboard_set("foo")

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
	elif event is InputEventMouseButton and event.position.x > Globals.controls_width - 13 and event.pressed and event_is_wheel_down(event):
		if event.is_shift_pressed():
			await move_top_and_bottom(Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4, Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4)
		else:
			await _on_button_zoom_minus_pressed(Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4, event.position.x - Globals.controls_width)
	elif event is InputEventMouseButton and event.position.x > Globals.controls_width - 13 and event.pressed and event_is_wheel_up(event):
		if event.is_shift_pressed():
			await move_top_and_bottom(-Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4, -Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4)
		else:
			await _on_button_zoom_plus_pressed(Globals.userdata.config.get_value("mouse", "wheel_sens") * 0.4, event.position.x - Globals.controls_width)
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
				if dragging == 1:
					selected_seq_range_start = top_genome.draw_pos_to_genome_and_contig_pos((dragging_rect.polygon[0].x - Globals.top_x_left + 50 + Globals.controls_width) / Globals.x_zoom)
					selected_seq_range_end = top_genome.draw_pos_to_genome_and_contig_pos((end - Globals.top_x_left - Globals.controls_width) / Globals.x_zoom)
				else:
					selected_seq_range_start = bottom_genome.draw_pos_to_genome_and_contig_pos((dragging_rect.polygon[0].x - Globals.bottom_x_left + 50 + Globals.controls_width) / Globals.x_zoom)
					selected_seq_range_end = bottom_genome.draw_pos_to_genome_and_contig_pos((end - Globals.bottom_x_left - Globals.controls_width) / Globals.x_zoom)

				selected_seq_range_start[1] = roundi(selected_seq_range_start[1])
				selected_seq_range_end[1] = roundi(selected_seq_range_end[1])
				var match_ids = matches.get_matches_in_range(min(start, end), max(start, end), dragging==1)
				top_genome.deselect_contig()
				bottom_genome.deselect_contig()
				top_genome.deselect_all_annot()
				bottom_genome.deselect_all_annot()
				contig_deselected.emit()
				enable_contig_ops.emit(false)
				if len(match_ids) > 0:
					multimatch_list_found.emit(match_ids)
				if dragging == 1:
					drag_range_selected.emit(Globals.TOP, selected_seq_range_start, selected_seq_range_end)
					top_genome.highlight_multi_sequence(selected_seq_range_start[0], selected_seq_range_start[1], selected_seq_range_end[0], selected_seq_range_end[1])
				else:
					drag_range_selected.emit(Globals.BOTTOM, selected_seq_range_start, selected_seq_range_end)
					bottom_genome.highlight_multi_sequence(selected_seq_range_start[0], selected_seq_range_start[1], selected_seq_range_end[0], selected_seq_range_end[1])
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


func _on_mult_matches_item_list_selected_an_annotation(annot_data):
	clear_sequence_highlights()
	if annot_data[0] == Globals.TOP:
		set_top_scrollbar_value(top_genome.get_percent_annot_feature_x_left(annot_data[1], annot_data[2]), true)
		top_genome.select_annot(annot_data[1], annot_data[2])
		bottom_genome.deselect_all_annot()
	else:
		set_bottom_scrollbar_value(bottom_genome.get_percent_annot_feature_x_left(annot_data[1], annot_data[2]), true)
		bottom_genome.select_annot(annot_data[1], annot_data[2])
		top_genome.deselect_all_annot()


func name_of_selected_contig():
	if contig_selected_is_top:
		return top_genome.name_of_selected_contig()
	else:
		return bottom_genome.name_of_selected_contig()


func _on_rev_button_pressed():
	if contig_selected_is_top:
		var selected_contig_id = top_genome.selected_contig
		await reverse_complement(Globals.TOP, selected_contig_id)
		top_genome.select_contig(selected_contig_id)
	else:
		var selected_contig_id = bottom_genome.selected_contig
		await reverse_complement(Globals.BOTTOM, selected_contig_id)
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
	move_selected_contig("start")


func _on_move_left_button_pressed():
	move_selected_contig("left")


func _on_move_right_button_pressed():
	move_selected_contig("right")


func _on_move_end_button_pressed():
	move_selected_contig("end")


func _on_genome_move_to_pos(top_or_bottom, mouse_x):
	var window_size = get_viewport().get_visible_rect().size
	var game_width = window_size.x - Globals.controls_width
	var middle = Globals.controls_width + 0.5 * game_width
	var to_move = (mouse_x - middle) / game_width
	if top_or_bottom == Globals.TOP:
		move_top_and_bottom(to_move, 0)
	else:
		move_top_and_bottom(0, to_move)


func _on_annotation_line_edit_annotation_search(search_text):
	var top_matches = top_genome.annotation_search(search_text)
	var bottom_matches = bottom_genome.annotation_search(search_text)
	var results = []
	for x in top_matches:
		results.append([Globals.TOP] + x)
	for x in bottom_matches:
		results.append([Globals.BOTTOM] + x)
	annotation_list_found.emit(results)
	

func _on_sequence_line_edit_sequence_search(search_text):
	var top_matches = top_genome.sequence_search(search_text)
	var bottom_matches = bottom_genome.sequence_search(search_text)
	var results = []
	for x in top_matches:
		results.append([Globals.TOP] + x + [len(search_text)])
		if len(results) >= Globals.max_search_results:
			break
			
	for x in bottom_matches:
		if len(results) >= Globals.max_search_results:
			break
		results.append([Globals.BOTTOM] + x + [len(search_text)])
		
	sequence_list_found.emit(results)


func _on_game_redraw_matches():
	matches.update_hide_and_show()


func clear_sequence_highlights():
	top_genome.clear_sequence_highlight()
	bottom_genome.clear_sequence_highlight()


func _on_mult_matches_item_list_selected_a_sequence(seq_data):
	top_genome.deselect_all_annot()
	bottom_genome.deselect_all_annot()
	top_genome.deselect_contig()
	bottom_genome.deselect_contig()
	matches.deselect()
	var range_end = seq_data[2] + seq_data[4] - 1
	if seq_data[0] == Globals.TOP:
		set_top_scrollbar_value(top_genome.get_percent_position_x_left(seq_data[1], seq_data[2]), true)
		top_genome.highlight_sequence(seq_data[1], seq_data[2], seq_data[1], range_end, seq_data[3])
		bottom_genome.clear_sequence_highlight()
		sequence_range_selected.emit(Globals.TOP, seq_data[1], seq_data[2], range_end, seq_data[3])
	else:
		set_bottom_scrollbar_value(bottom_genome.get_percent_position_x_left(seq_data[1], seq_data[2]), true)
		bottom_genome.highlight_sequence(seq_data[1], seq_data[2], seq_data[1], seq_data[2] + seq_data[4] - 1, seq_data[3])
		top_genome.clear_sequence_highlight()
		sequence_range_selected.emit(Globals.BOTTOM, seq_data[1], seq_data[2], range_end, seq_data[3])
