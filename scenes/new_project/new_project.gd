extends Control


signal update_top_genome_filename
signal update_bottom_genome_filename
signal update_project_dir
signal new_project_go_button
signal new_project_cancel
signal append_to_info_text

var filename1 = ""
var filename2 = ""


func _ready():
	hide()
	get_viewport().files_dropped.connect(on_files_dropped)


func clear_fields():
	filename1 = ""
	filename2 = ""
	update_top_genome_filename.emit("")
	update_bottom_genome_filename.emit("")


func on_files_dropped(files):
	if len(files) != 1:
		return
	if filename1 == "":
		filename1 = files[0]
		update_top_genome_filename.emit(filename1)
	elif filename2 == "":
		filename2 = files[0]
		update_bottom_genome_filename.emit(filename2)


	
func _on_go_button_pressed():
	# see https://github.com/godotengine/godot/issues/73296
	# found adding all these timeouts made the text label update.
	# Without them it doesn't change
	await get_tree().process_frame
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
