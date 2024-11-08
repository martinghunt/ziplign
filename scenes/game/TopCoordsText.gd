extends RichTextLabel


func _on_genomes_n_matches_match_selected(selected):
	text = Globals.proj_data.get_match_text(selected) 


func _on_genomes_n_matches_match_deselected():
	text = "None"
