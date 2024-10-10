extends Node

class_name UserData

func get_bin_path():
	return OS.get_user_data_dir().path_join("bin")

var home_dir = OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
var bin = get_bin_path()
var makeblastdb = bin.path_join("makeblastdb")
var blastn = bin.path_join("blastn")
var tnahelper = bin.path_join("tnahelper")
var data_dir = OS.get_user_data_dir()
var data_dir_exists = false
var bin_exists = false
var blastn_exists = false
var makeblastdb_exists = false
var tnahelper_exists = false
var current_proj_dir = OS.get_user_data_dir().path_join("current_proj")
var install_ok = false


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
	install_ok = bin_exists and tnahelper_exists and blastn_exists and makeblastdb_exists and makeblastdb_exists
	#OS.shell_open(bin)
	#OS.shell_open("https://www.startpage.com")




func _init():
	pass
	#print("Start of user_data init()")
	#check_all_paths()
	#print("Install ok:", install_ok)

