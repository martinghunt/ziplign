extends HScrollBar


func _ready():
	page = 1
	pass # Replace with function body.


func _on_genomes_n_matches_hscrollbar_set_bottom_value(x):
	set_value_no_signal(x)
