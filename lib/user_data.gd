class_name UserData

func get_bin_path():
	return OS.get_user_data_dir().path_join("bin")


func get_config_path():
	return OS.get_user_data_dir().path_join("config")

func check_bin():
	var bin = get_bin_path()
	print("Checking bin directory:", bin)

func _init():
	print("Start of user_data init()")
	check_bin()
