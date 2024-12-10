extends LineEdit

signal sequence_search

func _ready():
	text = ""

func _on_text_submitted(new_text):
	text = new_text
	sequence_search.emit(text)
	release_focus()

  
#func _on_focus_exited():
#	_on_text_submitted(text)
