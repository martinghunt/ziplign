extends RichTextLabel


func _on_genomes_n_matches_match_selected(selected):
	text = "Match: " + Globals.proj_data.get_match_text(selected) 


func _on_genomes_n_matches_match_deselected():
	text = "Nothing"


func _on_genomes_n_matches_contig_selected(top_or_bottom, contig_name):
	text = "Contig: " + top_or_bottom + " genome / " + contig_name


func _on_genomes_n_matches_contig_deselected():
	text = "Nothing"
