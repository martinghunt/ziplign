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


func _init(new_top_or_bottom, new_top, new_bottom):
	top_or_bottom = new_top_or_bottom
	top = new_top
	bottom = new_bottom
	var start = 100
	last_contig_end = 0
	
	for cname in Globals.proj_data.genome_seqs[top_or_bottom]["names"]:
		var clength = len(Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][cname])
		contig_names.append(cname)
		last_contig_end = start + clength
		contigs[cname] = ContigClass.new(len(contigs), start, last_contig_end, top, bottom, clength)
		base_contig_pos[cname] = [start, last_contig_end]
		start += contig_space + clength



func contig_length_from_index(i):
	return len(Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][contig_names[i]])


func contig_nt(index, pos):
	return Globals.proj_data.genome_seqs[top_or_bottom]["seqs"][contig_names[index]][pos]
	
	
func show_nuc_sequence(contig_index, genome_start, genome_end):
		var cname = contig_names[contig_index]
		var genome_plot_len = contigs[cname].x_end - contigs[cname].x_start
	
		genome_start = int(genome_start)
		genome_end = int(genome_end)
		var contig_length_in_bp = contig_length_from_index(contig_index)
		
		for i in range(genome_start, genome_end):
			var plot_x = contigs[cname].x_start + 1.0 * genome_plot_len * (i + 0.5) / contig_length_in_bp
			nt_labels.append(Label.new())
			nt_labels[-1].text = contig_nt(contig_index, i)
			nt_labels[-1].position.x = plot_x
			nt_labels[-1].position.y = top - 10
			nt_labels[-1].set_horizontal_alignment(1) # 1 = center
			nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
			add_child(nt_labels[-1])
			
			nt_labels.append(Label.new())
			nt_labels[-1].text = Globals.complement_dict.get(contig_nt(contig_index, i), "N")
			nt_labels[-1].position.x = plot_x
			nt_labels[-1].position.y = top + 10
			nt_labels[-1].set_horizontal_alignment(1) # 1 = center
			nt_labels[-1].add_theme_color_override("font_color", Globals.theme.colours["text"])
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
		return

	var new_zoomed = {}
	if left_genome_index == right_genome_index:
		show_nuc_sequence(left_genome_index, left_genome_pos, right_genome_pos)
		new_zoomed[contig_names[left_genome_index]] = true
		
	else:
		show_nuc_sequence(left_genome_index, left_genome_pos, contig_length_from_index(left_genome_index))
		for i in range(left_genome_index, right_genome_index):
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
	x_left = x
	reset_contig_coords()



func set_x_zoom(new_x_zoom):
	x_zoom = new_x_zoom
	reset_contig_coords()


#func set_top_bottom(new_top, new_bottom):
	#top = new_top
	#bottom = new_bottom
	#for ctg_name in contigs:
		#pass


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
	return [-1, 0]


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
