extends VBoxContainer


func _ready():
	hide()


func _on_genomes_n_matches_enable_contig_ops(enable):
	if enable:
		show()
	else:
		hide()
