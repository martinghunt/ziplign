extends Control

signal add_to_text_label
signal finished_downloading
signal init_finished

func _ready():
	show()


func download(url, outfile):
	add_to_text_label.emit("Downloading: " + url)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	http_request.set_download_file(outfile)
	var result = http_request.request(url)

	if result == OK:
		add_to_text_label.emit("... downloaded ok")
		return true
	else:
		add_to_text_label.emit("... error downloading. Result: " + result)
		return false

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		print("Download Failed")
	remove_child($HTTPRequest)
	finished_downloading.emit()


func download_tnahelper():
	var url = "https://github.com/martinghunt/tnahelper/releases/download/v0.3.2/tnahelper_"
	if Globals.userdata.os == "mac":
		url += "darwin_"
	else:
		url += Globals.userdata.os + "_"
	
	if "arm" in Globals.userdata.arch:
		url += "arm64"
	else:
		url += "amd64"
		
	var ok = download(url, Globals.userdata.tnahelper)
	await finished_downloading
	return ok


func chmod_make_executable(filename):
	var exit_code = OS.execute("chmod", ["+x", filename])
	if exit_code == 0:
		add_to_text_label.emit("Made executable: " + filename)
		return true
	else:
		add_to_text_label.emit("Error making executable: " + filename)
		return false


func size_of_blast_tarball():
	var dir = DirAccess.open(Globals.userdata.bin)
	for filename in dir.get_files():
		if filename.begins_with("ncbi-blast") and filename.ends_with(".tar.gz"):
			var f = FileAccess.open(Globals.userdata.bin.path_join(filename), FileAccess.READ)
			var size_mb = int(float(f.get_length()) / (1024 * 1024))
			print(filename, ", ", size_mb, "M")
			return size_mb
	return 0
			

func run_all():
	add_to_text_label.emit("TNA Version: " + ProjectSettings.get_setting("application/config/version"))
	add_to_text_label.emit("Running on " + Globals.userdata.os + "/" + Globals.userdata.arch)	
	Globals.userdata.check_all_paths()
	
	if not Globals.userdata.data_dir_exists:
		OS.alert("No user data folder found. Cannot continue. Expected to find: " + Globals.userdata.data_dir, "ERROR")
		return false
	
	add_to_text_label.emit("Data folder found: " + Globals.userdata.data_dir)
	await get_tree().create_timer(0.1).timeout

	if Globals.userdata.bin_exists:
		add_to_text_label.emit("Binaries folder found: " + Globals.userdata.bin)
	else:
		add_to_text_label.emit("Binaries folder not found: " + Globals.userdata.bin)
		add_to_text_label.emit(" ... creating: " + Globals.userdata.bin)
		await get_tree().create_timer(0.1).timeout
		var error = DirAccess.make_dir_recursive_absolute(Globals.userdata.bin)
		if error != OK:
			add_to_text_label.emit(" ... ERROR creating: " + Globals.userdata.bin)
			OS.alert("Error making folder for binaries.\nCannot continue.\nTried to make:\n" + Globals.userdata.bin, "ERROR")
			return false
		add_to_text_label.emit(" ... created: " + Globals.userdata.bin)
		Globals.userdata.bin_exists = true
		
	if Globals.userdata.tnahelper_exists:
		add_to_text_label.emit("tnahelper found: " + Globals.userdata.tnahelper)
	else:
		await get_tree().create_timer(0.1).timeout
		add_to_text_label.emit("tnahelper not found: " + Globals.userdata.tnahelper)
		var ok = await download_tnahelper()
		if not ok:
			OS.alert("Error downloading tnahelper.\nCannot continue", "ERROR")
			return false
		
		if Globals.userdata.os != "windows":
			print("making tnahelper executable")
			ok = chmod_make_executable(Globals.userdata.tnahelper)
			if not ok:
				OS.alert("Error making tnahelper executable.\nCannot continue", "ERROR")
				return false
			
		Globals.userdata.tnahelper_exists = true
		await get_tree().create_timer(0.1).timeout
		add_to_text_label.emit("tnahelper downloaded: " + Globals.userdata.tnahelper)
	
	Globals.userdata.set_tnahelper_version()
	add_to_text_label.emit("tnahelper version: " + Globals.userdata.tnahelper_version)
	
	var blast_ok = true
	if Globals.userdata.makeblastdb_exists:
		add_to_text_label.emit("makeblastdb found: " + Globals.userdata.makeblastdb)
	else:
		blast_ok = false
		add_to_text_label.emit("makeblastdb not found: " + Globals.userdata.makeblastdb)
		
	if Globals.userdata.blastn_exists:
		add_to_text_label.emit("blastn found: " + Globals.userdata.blastn)
		Globals.userdata.set_blastn_version()
		blast_ok = Globals.userdata.blastn_version != "unknown"
		add_to_text_label.emit("blastn version: ", Globals.userdata.blastn_version)
	else:
		blast_ok = false
		add_to_text_label.emit("blastn not found: " + Globals.userdata.blastn)
	
	await get_tree().create_timer(0.1).timeout
	
	
	if not blast_ok:
		add_to_text_label.emit("Some blast programs not found, or version unknown. Downloading...")
		var opts = ["download_binaries", "--outdir", Globals.userdata.bin]
		var stderr = []
		await get_tree().create_timer(0.1).timeout
		add_to_text_label.emit("Running: " + Globals.userdata.tnahelper + " " + " ".join(opts))
		add_to_text_label.emit("[b]This may take some time, depending on internet bandwidth[/b]")
		add_to_text_label.emit("Size of downloaded file (is up to around 200M total size): ")
		await get_tree().create_timer(0.1).timeout
		var thread = Thread.new()
		thread.start(OS.execute.bind(Globals.userdata.tnahelper, opts, stderr, true))
		while thread.is_alive():
			await get_tree().create_timer(3).timeout
			add_to_text_label.emit(" " + str(size_of_blast_tarball()) + "M", false)
		var exit_code = thread.wait_to_finish()
		add_to_text_label.emit("... blast downloaded")
		await get_tree().create_timer(0.1).timeout

		for x in stderr:
			print(x + "\n")
		if exit_code != 0:
			print("Error downloading blast")
			add_to_text_label.emit("Error downloading blast")
			OS.alert("Error downloading blast.\nCannot continue", "ERROR")
			return false

		add_to_text_label.emit(" ... finished downloading blast")
	
	if Globals.userdata.example_data_exists:
		add_to_text_label.emit("Example genome files found in " + Globals.userdata.example_data_dir)
	else:
		add_to_text_label.emit("Example genome files not found. Going to generate them")
		var opts = ["make_example_data", "--outdir", Globals.userdata.example_data_dir]
		var stderr = []
		var exit_code = OS.execute(Globals.userdata.tnahelper, opts, stderr, true)
		for x in stderr:
			print(x + "\n")
		if exit_code != 0:
			print("Error making example genome files")
			add_to_text_label.emit("Error making example genome files")
			OS.alert("Error making example genome files.\nCannot continue", "ERROR")
			return false
	
	if Globals.userdata.config_file_exists:
		add_to_text_label.emit("Config file found. Loading it. " + Globals.userdata.config_file)
		Globals.userdata.load_config()
	else:
		add_to_text_label.emit("Config file not found. Making default file. " + Globals.userdata.config_file)
		Globals.userdata.make_default_config()
		
	add_to_text_label.emit("Applying settings from config file")
	Globals.theme.set_theme(Globals.userdata.config.get_value("colours", "theme"))
	add_to_text_label.emit("Initialization finished")
	return true

func _on_main_start_init():
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var width_to_height = 1.0 * window_size.x / window_size.y
	var wanted_width = int(0.75 * screen_size.x)
	var wanted_height = 1 + int(wanted_width / width_to_height)
	print("Detected screen size: ", screen_size.x, "x", screen_size.y)
	print("Resize TNA window to: ", wanted_width, "x", wanted_height)
	DisplayServer.window_set_size(Vector2i(wanted_width, wanted_height))
	var top_left_for_center_x = screen_size.x / 2 - wanted_width
	DisplayServer.window_set_position(Vector2((screen_size.x - wanted_width) / 2, (screen_size.y - wanted_height) / 2))
	show()
	await run_all()
	await get_tree().create_timer(1).timeout
	hide()
	$"..".reset_colours()
	init_finished.emit()
