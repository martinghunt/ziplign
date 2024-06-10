extends Node

const ProjData = preload("res://lib/project_data.gd")
var proj_data = ProjData.new()


func get_ext_path():
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://ext")
	else:
		return OS.get_executable_path().get_base_dir().path_join("ext")


var ext_path = get_ext_path()
var genomes_viewport_width = 1000
var match_min_show_pc_id = 90.0
var match_min_show_length = 100
var match_aln_step = 1
var zoom_to_show_bp = 9.0
var controls_width = 140


var complement_dict = {
	"A": "T",
	"C": "G",
	"G": "C",
	"T": "A",
	"N": "N"
}
