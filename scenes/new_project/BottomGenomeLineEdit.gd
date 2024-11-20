extends LineEdit


func _on_new_project_update_bottom_genome_filename(new_text):
	text = new_text
	set_caret_column(len(text))


func _on_use_test_data_button_pressed():
	text = Globals.userdata.example_data_file2
	text_submitted.emit(text)
