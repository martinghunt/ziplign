extends LineEdit


signal annotation_search

func _ready():
	text = ""

func _on_text_submitted(new_text):
	text = new_text
	annotation_search.emit(text)
	release_focus()
