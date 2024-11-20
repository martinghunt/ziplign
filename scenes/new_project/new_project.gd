extends Control


signal update_top_genome_filename
signal update_bottom_genome_filename
signal new_project_go_button
signal new_project_cancel
signal append_to_info_text
signal clear_info_text
signal enable_go_button
signal set_status_text
signal reset_compare_line_edit

var filename1 = ""
var filename2 = ""


func _ready():
	hide()
	enable_go_button.emit(true)
	get_viewport().files_dropped.connect(on_files_dropped)


func clear_fields():
	filename1 = ""
	filename2 = ""
	update_top_genome_filename.emit("")
	update_bottom_genome_filename.emit("")
	enable_go_button.emit(false)
	clear_info_text.emit()
	reset_compare_line_edit.emit()
	update_status_text()

func set_filename1(filename):
	filename1 = filename
	update_top_genome_filename.emit(filename1)


func set_filename2(filename):
	filename2 = filename
	update_bottom_genome_filename.emit(filename2)


func update_go_button():
	enable_go_button.emit(filename1 != "" and filename2 != "")


func update_status_text():
	if filename1 == "" and filename2 == "":
		set_status_text.emit("Need both genomes. Drag+drop, or type in the boxes")
	elif filename1 == "":
		set_status_text.emit("Top genome required. Drag+drop or type in the box")
	elif filename2 == "":
		set_status_text.emit("Bottom genome required. Drag+drop or type in the box")
	else:
		set_status_text.emit("Ready to go. Press the start button")


func on_files_dropped(files):
	if len(files) == 1:
		var mouse_y = get_global_mouse_position().y
		var y_cutoff = $MainVBoxContainer/GridContainer/BottomGenomeLineEdit.global_position.y
		if mouse_y < y_cutoff:
			set_filename1(files[0])
		else:
			set_filename2(files[0])
	elif len(files) == 2:
		set_filename1(files[0])
		set_filename2(files[1])

	update_go_button()
	update_status_text()


func _on_go_button_pressed():
	# see https://github.com/godotengine/godot/issues/73296
	# found adding all these timeouts made the text label update.
	# Without them it doesn't change
	await get_tree().process_frame
	
	for l in [[filename1, "Top"], [filename2, "Bottom"]]:
		if FileAccess.file_exists(l[0]):
			append_to_info_text.emit(l[1] + " genome file found: " + l[0])
		else:
			append_to_info_text.emit("[color=red]" + l[1] + " genome file not found: " + l[0] + "[/color]")
			set_status_text.emit(l[1] + " genome not found! Reset and try again")
			return
		
	append_to_info_text.emit("Initialising data folder:\n  " + Globals.userdata.current_proj_dir)
	Globals.proj_data.create(Globals.userdata.current_proj_dir)
	await get_tree().create_timer(0.1).timeout
	
	append_to_info_text.emit("Start importing genomes:\n  " + filename1 + "\n  " + filename2)
	await get_tree().create_timer(0.1).timeout
	Globals.proj_data.import_genomes(filename1, filename2)
	
	append_to_info_text.emit("Genomes imported. Running blast")
	await get_tree().create_timer(0.1).timeout
	Globals.proj_data.run_blast()
	
	append_to_info_text.emit("Blast finished. Loading results")
	await get_tree().create_timer(0.1).timeout
	Globals.proj_data.load_blast_matches()
	
	append_to_info_text.emit("Laoading genomes")
	await get_tree().create_timer(0.1).timeout
	Globals.proj_data.load_genomes()
	
	append_to_info_text.emit("Loading annotation")
	await get_tree().create_timer(0.1).timeout
	Globals.proj_data.load_annotation_files()
	Globals.proj_data.set_data_loaded()
	hide()
	clear_fields()
	new_project_go_button.emit()


func _on_main_menu_new_project():
	clear_fields()
	show()


func _on_cancel_button_pressed():
	hide()
	clear_fields()
	new_project_cancel.emit()


func _on_top_genome_line_edit_text_submitted(new_text):
	set_filename1(new_text)
	update_go_button()
	update_status_text()


func _on_bottom_genome_line_edit_text_submitted(new_text):
	set_filename2(new_text)
	update_go_button()
	update_status_text()


func _on_reset_button_pressed():
	clear_fields()


func _on_open_file_manager_button_pressed():
	OS.shell_show_in_file_manager(Globals.userdata.home_dir)


func _on_top_genome_line_edit_text_changed(new_text):
	_on_top_genome_line_edit_text_submitted(new_text)


func _on_bottom_genome_line_edit_text_changed(new_text):
	_on_bottom_genome_line_edit_text_submitted(new_text)
