class_name UserData

func get_bin_path():
	return OS.get_user_data_dir().path_join("bin")

var home_dir = OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
var bin = get_bin_path()
var makeblastdb = bin.path_join("makeblastdb")
var blastn = bin.path_join("blastn")
var tnahelper = bin.path_join("tnahelper")
var bin_exists = false
var blastn_exists = false
var makeblastdb_exists = false
var tnahelper_exists = false
var current_proj_dir = OS.get_user_data_dir().path_join("current_proj")

func get_config_path():
	return OS.get_user_data_dir().path_join("config")

func check_bin():
	print("Checking bin directory:", bin)
	bin_exists = DirAccess.dir_exists_absolute(bin)
	print("bin dir exists:", bin_exists)
	blastn_exists = FileAccess.file_exists(blastn)
	print("blastn exists:", blastn_exists)
	makeblastdb_exists = FileAccess.file_exists(makeblastdb)
	print("makeblastdb exists:", makeblastdb_exists)
	tnahelper_exists = FileAccess.file_exists(tnahelper)
	print("tnahelper exists:", tnahelper_exists)


func _init():
	print("Start of user_data init()")
	check_bin()

