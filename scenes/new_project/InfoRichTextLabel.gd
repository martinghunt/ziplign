extends RichTextLabel


func _on_new_project_append_to_info_text(t):
	append_text(t)
	append_text("\n")


func _on_new_project_clear_info_text():
	text = ""
	clear()
