extends LineEdit


func _on_new_project_update_top_genome_filename(new_text):
	text = new_text


func _on_new_project_set_top_genome_line_edit_enable(b):
	set_selecting_enabled(b)


func _on_use_test_data_button_pressed():
	text = Globals.userdata.example_data_file1
	text_submitted.emit(text)
