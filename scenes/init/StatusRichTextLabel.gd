extends RichTextLabel


func _on_init_add_to_text_label(t, add_newline=true):
	append_text(t)
	if add_newline:
		append_text("\n")
