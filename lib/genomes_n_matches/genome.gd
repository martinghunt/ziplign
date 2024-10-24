extends Node

class_name Genome

const ContigClass = preload("contig.gd")


var contigs = {}
var base_contig_pos = {}
var contig_names = []
var hover_matches = {}
var selected = -1
var contig_space = 20
var top = 5
var bottom = 30
var tracks_y = {}
var coords_axis_y = {}
var x_zoom = 1.0
var x_left = 0
var last_contig_end = 0
var top_or_bottom = ""
var left_genome_index = ""
var left_genome_pos = 0
var right_genome_index = ""
var right_genome_pos = 0
var nt_labels = []
var zoomed_contigs = {}
var label_space_pixels = 200
var style_box_ctg_names = StyleBoxFlat.new()


func _init(new_top_or_bottom, new_top, new_bottom):
	style_box_ctg_names.bg_color = Globals.theme.colours["genomes_bg"]
	style_box_ctg_names.border_color = Globals.theme.colours["text"]
	top_or_bottom = new_top_or_bottom
	top = new_top
	bottom = new_bottom
	var total_height = bottom - top

	if top_or_bottom == "top":
		tracks_y["ctg_name"] = top - 11
		tracks_y["coords_top"] = top + 0.27 * total_height
		tracks_y["coords_bottom"] = top + 0.4 * total_height
		tracks_y["fwd_top"] = top + 0.4 * total_height
		tracks_y["fwd_bottom"] = top + 0.7 * total_height
		tracks_y["rev_top"] = top + 0.7 * total_height
		tracks_y["rev_bottom"] = top + total_height
	else:
		tracks_y["fwd_top"] = top
		tracks_y["fwd_bottom"] = top + 0.3 * total_height
		tracks_y["rev_top"] = top + 0.3 * total_height
		tracks_y["rev_bottom"] = top + 0.6 * total_height
		tracks_y["coords_top"] = top + 0.6 * total_height
		tracks_y["coords_bottom"] = top + 0.73 * total_height
		tracks_y["ctg_name"] = top + total_height
		

	if top_or_bottom == "top":
		coords_axis_y["coords"] = tracks_y["coords_top"] - 13
		coords_axis_y["tick_top"] = 0.5 * (tracks_y["coords_top"] + tracks_y["coords_bottom"])
		coords_axis_y["tick_bottom"] = tracks_y["fwd_top"] + 3
		coords_axis_y["tick_top_small"] = coords_axis_y["tick_top"]
		coords_axis_y["tick_bottom_small"] = tracks_y["fwd_top"]
		coords_axis_y["tick_top"] -= 3
	else:
		coords_axis_y["coords"] = tracks_y["coords_top"] + 11
		coords_axis_y["tick_bottom"] = 0.5 * (tracks_y["coords_top"] + tracks_y["coords_bottom"])
		coords_axis_y["tick_top"] = tracks_y["coords_top"] - 3
		coords_axis_y["tick_bottom_small"] = coords_axis_y["tick_bottom"]
		coords_axis_y["tick_top_small"] = tracks_y["coords_top"]
		coords_axis_y["tick_bottom"] += 3
	if not Globals.proj_data.has_annotation():
		coords_axis_y["coords"] -= 4
		if top_or_bottom == "top":
			tracks_y["ctg_name"] -= 10
	var start = 100
	last_contig_end = 0
	
	for cname in Globals.proj_data.genome_seqs[top_or_bottom]["names"]:
		var clength = len(Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][cname])
		contig_names.append(cname)
		last_contig_end = start + clength
		contigs[cname] = ContigClass.new(len(contigs), top_or_bottom, start, last_contig_end, tracks_y["fwd_top"], tracks_y["rev_bottom"], clength, Globals.proj_data.annotation[top_or_bottom].get(cname, {}))
		base_contig_pos[cname] = [start, last_contig_end]
		start += contig_space + clength


func contig_length_from_index(i):
	return len(Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][contig_names[i]])


func contig_nt(index, pos):
	return Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][contig_names[index]][pos]
	
	
func pos_to_human_readable(pos):
	if pos < 1000:
		return str(pos)
	elif pos < 1000000:
		return str(snapped(pos / 1000.0, 0.001)) + "k"
	else:
		return str(snapped(pos / 1000000.0, 0.00001)) + "M"


func pos_add_commas(pos):
	if pos < 1000:
		return str(pos)
	var x = str(pos).split()
	for i in range(3, len(x), 3):
		x[-(i+1)] += ","
	return "".join(x)


func show_coords_axis(contig_index, genome_start, genome_end, tick_space):
	var cname = contig_names[contig_index]
	var genome_plot_len = contigs[cname].x_end - contigs[cname].x_start
	genome_start = int(genome_start)
	genome_end = int(genome_end)
	var contig_length_in_bp = contig_length_from_index(contig_index)
	var start = max(tick_space, snappedi(genome_start - tick_space, tick_space))
	while len(range(start, genome_end, tick_space)) > 10:
		tick_space *= 1.1

	nt_labels.append(Label.new())
	nt_labels[-1].text = " " + cname
	var x = contigs[cname].x_start + 1.0 * genome_plot_len / contig_length_in_bp
	nt_labels[-1].position.x = max(Globals.controls_width, x) - 7
	nt_labels[-1].position.y = tracks_y["ctg_name"]
	nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
	nt_labels[-1].add_theme_stylebox_override("normal", style_box_ctg_names)
	nt_labels[-1].add_theme_font_override("font", Globals.fonts["dejavu"])
	nt_labels[-1].z_index = 10 + contig_index
	add_child(nt_labels[-1])


	for i in range(start, genome_end, tick_space):
		var plot_x = contigs[cname].x_start + 1.0 * genome_plot_len * i / contig_length_in_bp
		nt_labels.append(Line2D.new())
		nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_top"]))
		nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_bottom"]))
		nt_labels[-1].width = 2
		nt_labels[-1].default_color = Globals.theme.colours["text"]
		add_child(nt_labels[-1])

		nt_labels.append(Label.new())
		nt_labels[-1].text = pos_add_commas(i)
		nt_labels[-1].position.x = plot_x - 5
		nt_labels[-1].position.y = coords_axis_y["coords"]
		nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
		nt_labels[-1].add_theme_font_override("font", Globals.fonts["dejavu"])
		add_child(nt_labels[-1])


func show_nuc_sequence(contig_index, genome_start, genome_end):
	var cname = contig_names[contig_index]
	var genome_plot_len = contigs[cname].x_end - contigs[cname].x_start
	genome_start = int(genome_start)
	genome_end = int(genome_end)
	var contig_length_in_bp = contig_length_from_index(contig_index)
	var fwd_y
	var rev_y
	
	if top_or_bottom == "top":
		fwd_y = tracks_y["fwd_bottom"] - 15
		rev_y = tracks_y["fwd_bottom"] - 2
	else:
		fwd_y = tracks_y["fwd_bottom"] - 13
		rev_y = tracks_y["fwd_bottom"] 

	nt_labels.append(Label.new())
	nt_labels[-1].text = " " + cname
	var x = contigs[cname].x_start + 1.0 * genome_plot_len / contig_length_in_bp
	nt_labels[-1].position.x = max(Globals.controls_width, x) - 7
	nt_labels[-1].position.y = tracks_y["ctg_name"]
	nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
	nt_labels[-1].add_theme_stylebox_override("normal", style_box_ctg_names)
	nt_labels[-1].add_theme_font_override("font", Globals.fonts["dejavu"])
	nt_labels[-1].z_index = 10 + contig_index
	add_child(nt_labels[-1])

	
	for i in range(genome_start, genome_end):
		var plot_x = contigs[cname].x_start + 1.0 * genome_plot_len * i / contig_length_in_bp
		nt_labels.append(Label.new())
		nt_labels[-1].text = contig_nt(contig_index, i)
		nt_labels[-1].position.x = plot_x - 0.5 * Globals.font_acgt_sizes[contig_nt(contig_index, i)]
		nt_labels[-1].position.y = fwd_y
		nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
		nt_labels[-1].add_theme_font_size_override("font_size", Globals.font_acgt_size)
		nt_labels[-1].add_theme_font_override("font", Globals.fonts["mono"])
		add_child(nt_labels[-1])
		
		nt_labels.append(Label.new())
		nt_labels[-1].text = Globals.complement_dict.get(contig_nt(contig_index, i), "N")
		nt_labels[-1].position.x = plot_x - 0.5 * Globals.font_acgt_sizes[contig_nt(contig_index, i)]
		nt_labels[-1].position.y = rev_y
		nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
		nt_labels[-1].add_theme_font_size_override("font_size", Globals.font_acgt_size)
		nt_labels[-1].add_theme_font_override("font", Globals.fonts["mono"])
		add_child(nt_labels[-1])
		
		nt_labels.append(Line2D.new())
		if (i+1) % 10 == 0:
			nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_top"]))
			nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_bottom"]))
			nt_labels[-1].width = 2
		else:
			nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_top_small"]))
			nt_labels[-1].add_point(Vector2(plot_x, coords_axis_y["tick_bottom_small"]))
			nt_labels[-1].width = 1
		nt_labels[-1].default_color = Globals.theme.colours["text"]
		add_child(nt_labels[-1])
			
		if i > 1 and (i+1) % 20 == 0:
			nt_labels.append(Label.new())
			nt_labels[-1].text = pos_add_commas(i+1)
			nt_labels[-1].position.x = plot_x - 5
			nt_labels[-1].position.y = coords_axis_y["coords"]
			nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
			nt_labels[-1].add_theme_font_override("font", Globals.fonts["dejavu"])
			add_child(nt_labels[-1])


func clear_nt_labels():
	for l in nt_labels:
		l.free()
	nt_labels.clear()
	
	
func reset_contig_coords():
	for cname in contigs:
		contigs[cname].set_start_end(x_left + base_contig_pos[cname][0] * x_zoom, x_left + base_contig_pos[cname][1] * x_zoom)
	var result = draw_pos_to_genome_and_contig_pos(-x_left / x_zoom)
	left_genome_index = result[0]
	left_genome_pos = result[1]
	var v = get_viewport().get_visible_rect().size
	result = draw_pos_to_genome_and_contig_pos((v.x - x_left) / x_zoom)
	right_genome_index = result[0]
	right_genome_pos = result[1]

	clear_nt_labels()
		
	if x_zoom <= Globals.zoom_to_show_bp:
		for cname in zoomed_contigs:
			contigs[cname].set_zoomed_view(false)
		zoomed_contigs.clear()
		var bp_visible =  v.x /x_zoom
		var no_of_labels = v.x / label_space_pixels
		var label_space_bp = bp_visible / no_of_labels
		var units
		if label_space_bp < 1000:
			units = 1
		elif label_space_bp < 1000000:
			units = 1000
		elif label_space_bp < 1000000000:
			units = 1000000
		else:
			units = 1000000000
		
		label_space_bp = max(10, snappedi(label_space_bp, max(50, units)))

		if left_genome_index == right_genome_index:
			show_coords_axis(left_genome_index, left_genome_pos, right_genome_pos, label_space_bp)
		else:
			show_coords_axis(left_genome_index, left_genome_pos, contig_length_from_index(left_genome_index), label_space_bp)
			for i in range(left_genome_index + 1, right_genome_index):
				show_coords_axis(i, 0, contig_length_from_index(i), label_space_bp)
			show_coords_axis(right_genome_index, 0, right_genome_pos, label_space_bp)
		return

	var new_zoomed = {}
	if left_genome_index == right_genome_index:
		show_nuc_sequence(left_genome_index, left_genome_pos, right_genome_pos)
		new_zoomed[contig_names[left_genome_index]] = true
		
	else:
		show_nuc_sequence(left_genome_index, left_genome_pos, contig_length_from_index(left_genome_index))
		new_zoomed[contig_names[left_genome_index]] = true
		for i in range(left_genome_index + 1, right_genome_index):
			show_nuc_sequence(i, 0, contig_length_from_index(i))
			new_zoomed[contig_names[i]] = true
		show_nuc_sequence(right_genome_index, 0, right_genome_pos)
		new_zoomed[contig_names[right_genome_index]] = true

	for cname in new_zoomed:
		if cname not in zoomed_contigs:
			contigs[cname].set_zoomed_view(true)
			
	for cname in zoomed_contigs:
		if cname not in new_zoomed:
			contigs[cname].set_zoomed_view(false)
			
	zoomed_contigs = new_zoomed

func set_x_left(x):
	x_left = x + Globals.controls_width
	reset_contig_coords()



func set_x_zoom(new_x_zoom):
	x_zoom = new_x_zoom
	reset_contig_coords()


func _ready():
	for c in contigs:
		add_child(contigs[c])
		contigs[c].connect("mouse_in", on_mouse_in_contig)
		contigs[c].connect("mouse_out", on_mouse_out_contig)


func clear_all():
	clear_nt_labels()
	for c in contigs:
		remove_child(contigs[c])
		contigs[c].free()
	contigs.clear()
	

func draw_pos_to_genome_and_contig_pos(x):
	for i in len(contig_names):
		if x < base_contig_pos[contig_names[i]][1]:
			x = max(x, base_contig_pos[contig_names[i]][0])
			return  [i, x - base_contig_pos[contig_names[i]][0]]
	return [len(contig_names)-1, contig_length_from_index(len(contig_names)-1)]

func screen_x_pos_to_genome_contig_and_pos(screen_x):
	var x = (screen_x / x_zoom) - x_left
	return draw_pos_to_genome_and_contig_pos(x)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if len(hover_matches) == 1:
					var match_id = hover_matches.keys()[0]
					if selected != -1 and selected == match_id:
						return
					contigs[contig_names[selected]].deselect()
					contigs[contig_names[match_id]].select()
					selected = match_id
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if selected in hover_matches:
					contigs[contig_names[selected]].deselect()
					selected = -1


func on_mouse_in_contig(match_id):
	hover_matches[match_id] = true


func on_mouse_out_contig(match_id):
	hover_matches.erase(match_id)
