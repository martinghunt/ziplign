extends RichTextLabel


var annot_selected_top_or_bottom = ""
var annot_selected_contig_name = ""
var annot_selected_annot_id = -1

func _on_genomes_n_matches_match_selected(selected):
	text = "Match: " + Globals.proj_data.get_match_text(selected) 


func _on_genomes_n_matches_match_deselected():
	text = "Nothing"


func _on_genomes_n_matches_contig_selected(top_or_bottom, contig_name):
	text = "Contig: " + Globals.top_or_bottom_str[top_or_bottom] + " genome / " + contig_name


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


func _on_genomes_n_matches_sequence_range_selected(top_or_bottom, contig_name, start, end, is_rev):
	var coords_str
	if is_rev:
		coords_str = str(end + 1) + "-" + str(start + 1)
	else:
		coords_str = str(start + 1) + "-" + str(end + 1) 
	text = "Sequence: " + Globals.top_or_bottom_str[top_or_bottom] + " genome / " + str(contig_name) + " " + coords_str
