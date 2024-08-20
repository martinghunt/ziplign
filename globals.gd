extends Node

const ProjData = preload("res://lib/project_data.gd")
var proj_data = ProjData.new()
const UsrData = preload("res://lib/user_data.gd")
var userdata = UsrData.new()
const ColThemes = preload("res://lib/colour_themes.gd")
var theme = ColThemes.new()
#var theme = themes.theme

var bin_path = userdata.get_bin_path()
var genomes_viewport_width = 1000
var match_min_show_pc_id = 90.0
var match_min_show_length = 100
var match_aln_step = 1
var zoom_to_show_bp = 9.0
var controls_width = 140
var reload_needed = false


var complement_dict = {
	"A": "T",
	"C": "G",
	"G": "C",
	"T": "A",
	"N": "N"
}
