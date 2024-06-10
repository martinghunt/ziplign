extends RichTextLabel


func _on_genomes_n_matches_match_selected(selected):
	var d = Globals.proj_data.blast_matches[selected]
	text = d["qry"] + ":" + str(d["qstart"]) + "-" + str(d["qend"]) + " / " + d["ref"] + ":" + str(d["rstart"]) + "-" + str(d["rend"])  + " / pcid:" + str(d["pc"])


func _on_genomes_n_matches_match_deselected():
	text = "None"
