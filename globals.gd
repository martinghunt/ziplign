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
var zoom_to_show_annot_2k = 0.0001
var zoom_to_show_annot_1k = 0.0003
var zoom_to_show_annot_500 = 0.002
var zoom_to_show_annot_all = 0.006
var controls_width = 140
var reload_needed = false
var paused = true


var complement_dict = {
	"A": "T",
	"C": "G",
	"G": "C",
	"T": "A",
	"N": "N"
}


func load_fonts():
	var f = {
		"dejavu": load("res://fonts/dejavu-sans/DejaVuSans.ttf"),
		"mono": load("res://fonts/Anonymous-Pro/Anonymous_Pro.ttf"),
		"mono_bold": load("res://fonts/Anonymous-Pro/Anonymous_Pro_B.ttf")
	}
	for x in f:
		pass
		f[x].subpixel_positioning = 0
		f[x].multichannel_signed_distance_field = true
		#fonts[x].antialiasing = 2
		#fonts[x].hinting = 0
	return f
	
	

func get_char_sizes(font, font_size):
	var sizes = {}
	for c in ["A", "C", "G", "T", "N"]:
		sizes[c] = font.get_string_size(c, 0, -1, font_size)[0]
	return sizes

var fonts = load_fonts()
var font_acgt_size = 15
var font_acgt_sizes = get_char_sizes(fonts["mono"], font_acgt_size)
var font_annot_size = 12


func make_tooltip_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.4, 0.6)  # Set your preferred background color here
	#tooltip_style.border_width_all = 2
	style.border_color = Color(0.8, 0.8, 0.8)  # Optional: Set border color if needed
	return style
	
var tooltip_style = make_tooltip_style()
