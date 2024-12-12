extends RichTextLabel


var annot_selected_top_or_bottom = ""
var annot_selected_contig_name = ""
var annot_selected_annot_id = -1
var region_selected_data = []
var selected_top_or_bottom = -1
var selected_contig_id = -1
var selected_seq_start = -1
var selected_seq_end = -1

func _on_genomes_n_matches_match_selected(selected):
	text = "Match: " + Globals.proj_data.get_match_text(selected) 


func _on_genomes_n_matches_match_deselected():
	text = "Nothing"


func _on_genomes_n_matches_contig_selected(top_or_bottom, contig_id):
	selected_top_or_bottom = top_or_bottom
	selected_contig_id = contig_id
	text = "Contig: " + Globals.top_or_bottom_str[top_or_bottom] + \
		" genome / " + Globals.proj_data.contig_name(top_or_bottom, contig_id)


func _on_genomes_n_matches_contig_deselected():
	text = "Nothing"


func _on_genomes_n_matches_annot_selected(top_or_bottom, contig_name, annot_id, annot):
	annot_selected_top_or_bottom = top_or_bottom
	annot_selected_contig_name = contig_name
	annot_selected_annot_id = annot_id
	text = "Annotation: " + Globals.top_or_bottom_str[top_or_bottom] + " / " + str(contig_name) + ":" + str(annot)


func _on_genomes_n_matches_annot_deselected(top_or_bottom, contig_name, annot_id):
	if top_or_bottom != annot_selected_top_or_bottom \
	or contig_name != annot_selected_contig_name \
	or annot_id != annot_selected_annot_id:
		return
	annot_selected_top_or_bottom = ""
	annot_selected_contig_name = ""
	annot_selected_annot_id = -1
	if not text.begins_with("Match"):
		text = "Nothing"


func _on_genomes_n_matches_sequence_range_selected(top_or_bottom, contig_id, start, end, is_rev):
	var coords_str
	if is_rev:
		coords_str = str(end + 1) + "-" + str(start + 1)
		selected_seq_start = end
		selected_seq_end = start
	else:
		coords_str = str(start + 1) + "-" + str(end + 1)
		selected_seq_start = start
		selected_seq_end = end
	text = "Sequence: " + Globals.top_or_bottom_str[top_or_bottom] + " genome / " + \
		Globals.proj_data.contig_name(top_or_bottom, contig_id) +  \
		" " + coords_str
	selected_top_or_bottom = top_or_bottom
	selected_contig_id = contig_id


func _on_genomes_n_matches_drag_range_selected(top_or_bottom, range_start, range_end):
	region_selected_data = [top_or_bottom, range_start, range_end]

	text = "Region: " + Globals.top_or_bottom_str[top_or_bottom] + " " + \
		Globals.proj_data.contig_name(top_or_bottom, range_start[0]) + \
		":" + str(range_start[1] + 1) + " to " + \
		Globals.proj_data.contig_name(top_or_bottom, range_end[0]) + \
		":" + str(range_end[1] + 1)


func _on_copy_to_clipboard_button_pressed():
	if text.begins_with("Nothing"):
		return
	elif text.begins_with("Contig: "):
		DisplayServer.clipboard_set(
			Globals.userdata.os_newline.join(
				Globals.proj_data.contig_fasta_lines(selected_top_or_bottom, selected_contig_id)
		))
	elif text.begins_with("Region: "):
		DisplayServer.clipboard_set(
			Globals.userdata.os_newline.join(
				Globals.proj_data.range_to_seq_lines(region_selected_data[0], region_selected_data[1], region_selected_data[2])
		))
	elif text.begins_with("Sequence: "):
		DisplayServer.clipboard_set(
			Globals.userdata.os_newline.join(
				Globals.proj_data.contig_fasta_subseq(selected_top_or_bottom, selected_contig_id, selected_seq_start, selected_seq_end)
		))
	else:
		DisplayServer.clipboard_set(text.split(" ", false, 1)[1])
