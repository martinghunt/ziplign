extends Node

class_name UserData

func get_os():
	var os = OS.get_name()
	match os:
		"Windows":
			return "windows"
		"macOS":
			return "mac"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "linux"

	# TODO: handle this properly
	print("Unsupported OS: ", os)
	OS.alert("Error! Unsupported OS: " + os + ". Cannot continue.", "Error!")
	return null


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
var example_data_exists = false
var current_proj_dir = OS.get_user_data_dir().path_join("current_proj")
var install_ok = false


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
	var arch = Engine.get_architecture_name()
	if "x86" in arch or "arm" in arch:
		return arch
	else:
		# TODO: handle this properly
		print("unsupported architecture: ", arch)
		OS.alert("Error! Unsupported architecture: " + arch + ". Cannot continue.", "Error!")
		return null

var os = get_os()
var arch = get_architecture()


func get_config_path():
	return OS.get_user_data_dir().path_join("config")

func check_all_paths():
	data_dir_exists = DirAccess.dir_exists_absolute(data_dir)
	print("Checking bin directory:", bin)
	bin_exists = DirAccess.dir_exists_absolute(bin)
	print("bin dir exists:", bin_exists)
	blastn_exists = FileAccess.file_exists(blastn)
	print("blastn exists:", blastn_exists)
	makeblastdb_exists = FileAccess.file_exists(makeblastdb)
	print("makeblastdb exists:", makeblastdb_exists)
	tnahelper_exists = FileAccess.file_exists(tnahelper)
	print("tnahelper exists:", tnahelper_exists)
	example_data_exists = does_example_data_exist()
	print("example data found:", example_data_exists)
	install_ok = bin_exists and tnahelper_exists and blastn_exists and makeblastdb_exists and makeblastdb_exists and example_data_exists


func _init():
	pass
