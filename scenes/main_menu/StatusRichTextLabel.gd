extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	regenerate_text()


func regenerate_text():
	text = "" # otherwise text isn't actually cleared in the next line
	text = "Ziplign Version: " + ProjectSettings.get_setting("application/config/version")
	append_text("\nRunning on " + Globals.userdata.os + "/" + Globals.userdata.arch)
	append_text("\nzlhelper version: " + Globals.userdata.zlhelper_version)
	append_text("\nblastn version: " + Globals.userdata.blastn_version)

	if Globals.userdata.install_ok:
		append_text("\nInstall status: ok")
	if not Globals.userdata.install_ok:
		var zlhelper_str
		if Globals.userdata.zlhelper_exists:
			if Globals.userdata.zlhelper_version_ok:
				zlhelper_str = "found"
			else:
				zlhelper_str = "[color=red]bad version " + Globals.userdata.zlhelper_version + "[/color]"
		else:
			zlhelper_str = "[color=red]not found[/color]"

		var lookup = {true: "found", false: "[color=red]not found[/color]"}
		append_text("\n[color=red]Install status: bad![/color]")
		append_text("\nFolder/file checks:")
		append_text("\n  Data folder - " + lookup[Globals.userdata.data_dir_exists])
		append_text("\n  zlhelper - " + zlhelper_str)
		append_text("\n  makeblastdb - " + lookup[Globals.userdata.makeblastdb_exists])
		append_text("\n  blastn - " + lookup[Globals.userdata.blastn_exists])
		append_text("\n  blastn version - " + lookup[Globals.userdata.blastn_version != "unknown"])
		append_text("\n  Example data - " + lookup[Globals.userdata.example_data_exists])


func _on_main_menu_rerun_status_check():
	Globals.userdata.check_all_paths()
	regenerate_text()
