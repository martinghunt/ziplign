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

func load_dejavu():
	var dj = load("res://fonts/dejavu-sans/DejaVuSans.ttf")
	#dejavu.antialiasing = 2
	#dejavu.hinting = 0
	#dejavu.multichannel_signed_distance_field = true
	#dejavu.generate_mipmaps = true
	return dj
	
func get_char_sizes(font_size):
	var sizes = {}
	for c in ["A", "C", "G", "T", "N"]:
		sizes[c] = dejavu.get_string_size(c, 0, -1, font_size)[0]
	return sizes

var dejavu = load_dejavu()
var font_acgt_size = 13
var font_acgt_sizes = get_char_sizes(font_acgt_size)
