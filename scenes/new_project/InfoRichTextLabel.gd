extends RichTextLabel



func _ready():
	pass
	

func _on_new_project_append_to_info_text(t, newline=true):
	append_text(t)
	if newline:
		append_text("\n")
	var scrollbar = $"..".get_v_scroll_bar()
	await scrollbar.changed
	$"..".scroll_vertical = scrollbar.max_value


func _on_new_project_clear_info_text():
	text = ""
	clear()
