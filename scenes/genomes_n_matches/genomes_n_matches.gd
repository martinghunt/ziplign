extends Node2D

signal hscrollbar_set_top_value
signal hscrollbar_set_bottom_value
signal match_selected
signal match_deselected

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
	set_x_zoom(get_default_x_zoom())
	matches.connect("moved_to_selected_match", _on_moved_to_selected_match)
	matches.connect("match_selected", _on_match_selected)
	matches.connect("match_deselected", _on_match_deselected)
	$"../../../../ColorRect/ProcessingLabel".position.y = 0.5 * (global_top + global_bottom) - 20 - Globals.y_offset_not_paused
	$"../../../../ColorRect/ProcessingLabel".position.x = Globals.controls_width + 10


func get_default_x_zoom():
	return Globals.genomes_viewport_width / (1.05 * max_genome_x)

func set_x_zoom(zoom):
	x_zoom = zoom
	top_genome.set_x_zoom(x_zoom)
	bottom_genome.set_x_zoom(x_zoom)
	matches.set_x_zoom(x_zoom)
	if matches.move_to_selected() == -1:
		_on_right_top_scrollbar_value_changed(top_scrollbar_value)
		_on_right_bottom_scrollbar_value_changed(bottom_scrollbar_value)


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
	top_genome.set_x_left(1)
	bottom_genome.set_x_left(1)
	matches.set_top_x_left(1)
	matches.set_bottom_x_left(1)
	hscrollbar_set_top_value.emit(0)
	hscrollbar_set_bottom_value.emit(0)
	top_scrollbar_value = 0
	bottom_scrollbar_value = 0
	set_x_zoom(get_default_x_zoom())


func _on_button_zoom_minus_pressed():
	if x_zoom <= max(get_default_x_zoom() / 2, 0.00011):
		pass
	elif x_zoom <= 0.0011:
		set_x_zoom(x_zoom - 0.0001)
	elif x_zoom <= 0.011:
		set_x_zoom(x_zoom - 0.001)
	elif x_zoom <= 0.11:
		set_x_zoom(x_zoom - 0.01)
	elif x_zoom <= 1:
		set_x_zoom(x_zoom - 0.1)
	else:
		set_x_zoom(x_zoom - 1)


func _on_button_zoom_plus_pressed():
	if x_zoom >= 20:
		pass
	elif x_zoom >= 1:
		set_x_zoom(x_zoom + 1)
	elif x_zoom >= 0.1:
		set_x_zoom(x_zoom + 0.1)
	elif x_zoom >= 0.01:
		set_x_zoom(x_zoom + 0.01)
	elif x_zoom >= 0.001:
		set_x_zoom(x_zoom + 0.001)
	else:
		set_x_zoom(x_zoom + 0.0001)

	
func _on_button_zoom_bp_pressed():
	set_x_zoom(1.01 * Globals.zoom_to_show_bp)

func _on_moved_to_selected_match(selected):
	var s = matches.matches[selected]
	var x_top = min(s.start1, s.end1) * x_zoom - 20
	var x_bottom = x_zoom * s.start2 - 20
	top_genome.set_x_left(-x_top)
	bottom_genome.set_x_left(-x_bottom)
	matches.set_x_lefts(-x_top, -x_bottom)
	var x = 100 *  (x_top - 1) / (x_zoom * top_genome.last_contig_end)
	hscrollbar_set_top_value.emit(x)
	top_scrollbar_value = x
	x = 100 * (x_bottom - 1) / (x_zoom * bottom_genome.last_contig_end)
	hscrollbar_set_bottom_value.emit(x)
	bottom_scrollbar_value = x


func _on_match_selected(selected):
	match_selected.emit(selected)


func _on_match_deselected():
	match_deselected.emit()


func _on_game_new_project_go():
	top_genome.clear_all()
	bottom_genome.clear_all()
	matches.clear_all()
	remove_child(top_genome)
	remove_child(bottom_genome)
	remove_child(matches)
	_ready()


func shift_top(x_shift):
	top_scrollbar_value += x_shift
	_on_right_top_scrollbar_value_changed(top_scrollbar_value)
	hscrollbar_set_top_value.emit(top_scrollbar_value)


func shift_bottom(x_shift):
	bottom_scrollbar_value += x_shift
	_on_right_bottom_scrollbar_value_changed(bottom_scrollbar_value)
	hscrollbar_set_bottom_value.emit(bottom_scrollbar_value)


func move_top_and_bottom(top_frac, bottom_frac):
	var d = 80 * get_viewport().get_visible_rect().size.x / x_zoom
	shift_top(d * top_frac / top_genome.last_contig_end)
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
	

func reverse_complement(to_rev):
	start_processing_overlay()
	await get_tree().create_timer(0.1).timeout
	
	if to_rev == "top":
		Globals.proj_data.reverse_complement_genome("top")
	elif to_rev == "bottom":
		Globals.proj_data.reverse_complement_genome("bottom")

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


func _on_button_move_left_left_pressed():
	move_top_and_bottom(-0.5, -0.5)
	

func _on_button_move_left_right_pressed():
	move_top_and_bottom(0.25, -0.25)


func _on_button_move_right_left_pressed():
	move_top_and_bottom(-0.25, 0.25)


func _on_button_move_right_right_pressed():
	move_top_and_bottom(0.5, 0.5)


func _on_game_window_resized():
	matches.update_hide_and_show()
	top_genome.reset_contig_coords()
	bottom_genome.reset_contig_coords()
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
