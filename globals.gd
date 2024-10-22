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


func load_fonts():
	var fonts = {
		"dejavu": load("res://fonts/dejavu-sans/DejaVuSans.ttf"),
		"mono": load("res://fonts/Anonymous-Pro/Anonymous_Pro.ttf"),
		"mono_bold": load("res://fonts/Anonymous-Pro/Anonymous_Pro_B.ttf")
	}
	for x in fonts:
		pass
		fonts[x].subpixel_positioning = 0
		fonts[x].multichannel_signed_distance_field = true
		#fonts[x].antialiasing = 2
		#fonts[x].hinting = 0
	return fonts
	
	

func get_char_sizes(font, font_size):
	var sizes = {}
	for c in ["A", "C", "G", "T", "N"]:
		sizes[c] = font.get_string_size(c, 0, -1, font_size)[0]
	return sizes

var fonts = load_fonts()
var font_acgt_size = 15
var font_acgt_sizes = get_char_sizes(fonts["mono"], font_acgt_size)
