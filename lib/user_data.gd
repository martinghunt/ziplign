extends Node

class_name UserData


var default_config = {
	"colours": {"theme": "Light"},
	"mouse": {
		"wheel_sens": 1,
		"invert_wheel": false,
	},
	"trackpad": {
		"v_sens": 1,
		"invert_v": false,
		"h_sens": 1,
		"p_sens": 1,
	},
	"blast": {"share_data": false},
	"other": {
		"max_matches_on_screen": 500,
		"fasta_line_length": 60,
	},
}


func get_os():
	var got_os = OS.get_name()
	match got_os:
		"Windows":
			return "windows"
		"macOS":
			return "mac"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "linux"

	# TODO: handle this properly
	print("Unsupported OS: ", got_os)
	OS.alert("Error! Unsupported OS: " + got_os + ". Cannot continue.", "Error!")
	return null

func get_os_newline():
	if get_os() == "windows":
		return "\r\n"
	else:
		return "\n"

var os_newline = get_os_newline()


func get_bin_path():
	return OS.get_user_data_dir().path_join("bin")


func get_example_data_dir():
	return OS.get_user_data_dir().path_join("example_data")


func fix_windows_binary(b):
	if get_os() == "windows":
		return b + ".exe"
	else:
		return b


var home_dir = OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
var bin = get_bin_path()
var makeblastdb = fix_windows_binary(bin.path_join("makeblastdb"))
var blastn = fix_windows_binary(bin.path_join("blastn"))
var tnahelper = fix_windows_binary(bin.path_join("tnahelper"))
var example_data_dir = get_example_data_dir()
var data_dir = OS.get_user_data_dir()
var example_data_file1 = example_data_dir.path_join("g1.gff")
var example_data_file2 = example_data_dir.path_join("g2.gff")
var data_dir_exists = false
var bin_exists = false
var blastn_exists = false
var makeblastdb_exists = false
var tnahelper_exists = false
var tnahelper_version_ok = false
var example_data_exists = false
var current_proj_dir = OS.get_user_data_dir().path_join("current_proj")
var install_ok = false
var config_file = OS.get_user_data_dir().path_join("config")
var config_file_exists = false
var config = ConfigFile.new()
var tnahelper_version = "unknown"
var blastn_version = "unknown"
var blast_options = "-evalue 0.1"
var default_blast_options = "-evalue 0.1"

func does_example_data_exist():
	if DirAccess.dir_exists_absolute(example_data_dir):
		print("example data dir exists: ", example_data_dir)
	else:
		print("example data dir not found: ", example_data_dir)
		return false
	if FileAccess.file_exists(example_data_file1):
		print("example data genome file 1 exists: ", example_data_file1)
	else:
		return false
	if FileAccess.file_exists(example_data_file2):
		print("example data genome file 2 exists: ", example_data_file2)
	else:
		return false
	return true


func get_architecture():
	var got_arch = Engine.get_architecture_name()
	if "x86" in got_arch or "arm" in got_arch:
		return got_arch
	else:
		# TODO: handle this properly
		print("unsupported architecture: ", got_arch)
		OS.alert("Error! Unsupported architecture: " + got_arch + ". Cannot continue.", "Error!")
		return null

var os = get_os()
var arch = get_architecture()


func run_os_execute_get_output(to_execute, options):
	print("Running: ", to_execute, " ", " ".join(options))
	var output = []
	var exit_code = OS.execute(to_execute, options, output, true)
	if exit_code != 0:
		print("Error running ", to_execute, ". output: ", output)
	return output[0].rstrip("\n").rstrip("\r").split("\n")


func set_tnahelper_version():
	tnahelper_version = "unknown"
	var output = run_os_execute_get_output(tnahelper, ["-v"])
	if len(output) == 1:
		var fields = output[0].rstrip("\r").split(" ")
		if len(fields) == 3 and fields[0] == "tnahelper" and fields[1] == "version":
			tnahelper_version = fields[2]
	tnahelper_version_ok = tnahelper_version == Globals.expect_tnahelper_version
	if config.get_value("dev", "ignore_tnahelper_version", false):
		tnahelper_version_ok = true


func set_blastn_version():
	blastn_version = "unknown"
	var output = run_os_execute_get_output(blastn, ["-version"])
	if len(output) > 0:
		var fields = output[0].rstrip("\r").split(" ")
		if len(fields) == 2 and fields[0] == "blastn:":
			blastn_version = fields[1]


func check_all_paths():
	data_dir_exists = DirAccess.dir_exists_absolute(data_dir)
	print("Checking bin directory:", bin)
	bin_exists = DirAccess.dir_exists_absolute(bin)
	print("bin dir exists:", bin_exists)
	blastn_exists = FileAccess.file_exists(blastn)
	print("blastn exists:", blastn_exists)
	makeblastdb_exists = FileAccess.file_exists(makeblastdb)
	print("makeblastdb exists:", makeblastdb_exists)
	set_blastn_version()
	print("blastn version:", blastn_version)
	tnahelper_exists = FileAccess.file_exists(tnahelper)
	print("tnahelper exists:", tnahelper_exists)
	example_data_exists = does_example_data_exist()
	print("example data found:", example_data_exists)
	config_file_exists = FileAccess.file_exists(config_file)
	print("config file found:", config_file_exists)
	install_ok = bin_exists and tnahelper_exists and tnahelper_version_ok \
		and blastn_exists and makeblastdb_exists and makeblastdb_exists \
		and example_data_exists and config_file_exists \
		and blastn_version != "unknown"
	
	
func make_default_config():
	config.clear()
	for section in default_config:
		for key in default_config[section]:
			config.set_value(section, key, default_config[section][key])
	config.save(config_file)


func load_config():
	config.load(config_file)
	var any_missing = false
	for section in default_config:
		for key in default_config[section]:
			if not config.has_section_key(section, key):
				config.set_value(section, key, default_config[section][key])
				any_missing = true
	
	if any_missing:
		save_config()
		

func save_config():
	config.save(config_file)


func _init():
	pass
