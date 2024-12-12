extends LineEdit

var fasta_line_length: int


func _ready():
	fasta_line_length = Globals.userdata.config.get_value("other", "fasta_line_length", 60)
	text = str(fasta_line_length)


func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		fasta_line_length = int(new_text)
		if fasta_line_length < 0:
			fasta_line_length = 0
			new_text = "0"
		text = new_text
		Globals.userdata.config.set_value("other", "fasta_line_length", fasta_line_length)
	else:
		text = str(fasta_line_length)


func _on_focus_exited():
	_on_text_submitted(text)
