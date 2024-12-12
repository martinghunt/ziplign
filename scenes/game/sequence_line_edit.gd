extends LineEdit

signal sequence_search

func _ready():
	text = ""


func _on_text_submitted(new_text):
	new_text = new_text.strip_edges()
	text = new_text
	sequence_search.emit(text)
	release_focus()


func _gui_input(event):
	if Globals.paused:
		return

	if event.is_action_pressed("ui_paste"):
		var lines = DisplayServer.clipboard_get().strip_edges().split("\n")
		var start = 0
		if lines[0][0] == ">":
			start = 1
			
		var i = start
		while i < len(lines) and lines[i][0] != ">":
			lines[i] = lines[i].strip_edges()
			i += 1

		clear()
		await get_tree().create_timer(0.01).timeout
		set_text("".join(lines.slice(start, i)))
