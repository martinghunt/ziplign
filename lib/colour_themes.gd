class_name ColourThemes


var solarized = {
	"base03": "#002b36",
	"base02": "#073642",
	"base01": "#586e75",
	"base00": "#657b83",
	"base0": "#839496",
	"base1": "#93a1a1",
	"base2": "#eee8d5",
	"base3": "#fdf6e3",
	"yellow": "#b58900",
	"orange": "#cb4b16",
	"red": "#dc322f",
	"magenta": "#d33682",
	"violet": "#6c71c4",
	"blue": "#268bd2",
	"cyan": "#2aa198",
	"green": "#859900",
}


var colour_themes = {
	"Classic": {
		"ui": {
			"text": "black",
			"text_hover": "white",
			"button_bg": "silver",
			"button_highlight": "black",
			"button_pressed": "dimgray",
			"general_bg": "white",
			"panel_bg": "gainsboro"
		},
		"blast_match": {
			"fwd": "red",
			"rev": "blue",
			"fwd_hover": "pink",
			"rev_hover": "light_blue",
			"selected": "yellow",
			"outline": "black",
			"bp_match": "darkred",
			"bp_match_end": "black",
			"bp_mismatch": "orange",
		},
		"contig": {
			"edge": "black",
			"edge_hover": "gray",
			"edge_selected": "red",
			"fill": "dark_orange",
			"fill_hover": "white",
			"fill_selected": "yellow",
		},
		"text": "black",
		"genomes_bg": "white"
	},
	"Solarized dark": {
		"ui": {
			"text": solarized["base3"],
			"text_hover": solarized["base03"],
			"button_bg": solarized["base01"],
			"button_highlight": solarized["base3"],
			"button_pressed": solarized["base0"],
			"general_bg": solarized["base03"],
			"panel_bg": solarized["base02"],
		},
		"blast_match": {
			"fwd": solarized["red"],
			"rev": solarized["blue"],
			"fwd_hover": solarized["magenta"],
			"rev_hover": solarized["violet"],
			"selected": solarized["orange"],
			"outline": solarized["base1"],
			"bp_match": solarized["base02"],
			"bp_match_end": solarized["base02"],
			"bp_mismatch": solarized["base3"],
		},
		"contig": {
			"edge": solarized["base3"],
			"edge_hover": "gray",
			"edge_selected": "red",
			"fill": solarized["yellow"],
			"fill_hover": "white",
			"fill_selected": "yellow",
		},
		"text": solarized["base3"],
		"genomes_bg": solarized["base03"],
	},
	"Solarized light": {
		"ui": {
			"text": solarized["base03"],
			"text_hover": solarized["base3"],
			"button_bg": solarized["base1"],
			"button_highlight": solarized["base03"],
			"button_pressed": solarized["base02"],
			"general_bg": solarized["base3"],
			"panel_bg": solarized["base2"],
		},
		"blast_match": {
			"fwd": solarized["red"],
			"rev": solarized["blue"],
			"fwd_hover": solarized["magenta"],
			"rev_hover": solarized["violet"],
			"selected": solarized["orange"],
			"outline": solarized["base1"],
			"bp_match": solarized["base02"],
			"bp_match_end": solarized["base02"],
			"bp_mismatch": solarized["base3"],
		},
		"contig": {
			"edge": solarized["base3"],
			"edge_hover": "gray",
			"edge_selected": "red",
			"fill": solarized["yellow"],
			"fill_hover": "white",
			"fill_selected": "yellow",
		},
		"text": solarized["base03"],
		"genomes_bg": solarized["base3"],
	},
	"Dark": {
		"ui": {
			"text": Color(0.95, 0.95, 0.95),
			"text_hover": "black",
			"button_bg": Color(0.2, 0.2, 0.2),
			"button_highlight": Color(0.95, 0.95, 0.95),
			"button_pressed": "gainsboro",
			"general_bg": "black",
			"panel_bg": Color(0.1, 0.1, 0.1),
		},
		"blast_match": {
			"fwd": Color(0.3, 0.15, 0.15),
			"rev": Color(0.15, 0.15, 0.3),
			"fwd_hover": Color(0.5, 0.15, 0.15),
			"rev_hover": Color(0.15, 0.15, 0.5),
			"selected": Color(0.25, 0.25, 0.25),
			"outline": Color(0.95, 0.95, 0.95),
			"bp_match": Color(0.5, 0.5, 0.5),
			"bp_match_end": Color(0.5, 0.5, 0.5),
			"bp_mismatch": Color(0.95, 0.95, 0.95),
		},
		"contig": {
			"edge": Color(0.8, 0.8, 0.8),
			"edge_hover": "gray",
			"edge_selected": "red",
			"fill": Color(0.2, 0.2, 0.2),
			"fill_hover": "white",
			"fill_selected": "yellow",
		},
		"text": Color(0.95, 0.95, 0.95),
		"genomes_bg": "black",
	},
	"Light": {
		"ui": {
			"text": Color(0.1, 0.1, 0.1),
			"text_hover": "white",
			"button_bg": Color(0.8, 0.8, 0.8),
			"button_highlight": Color(0.1, 0.1, 0.1),
			"button_pressed": "gainsboro",
			"general_bg": "white",
			"panel_bg": Color(0.9, 0.9, 0.9),
		},
		"blast_match": {
			"fwd": "firebrick",
			"rev": "darkslateblue",
			"fwd_hover": "indianred",
			"rev_hover": "slateblue",
			"selected": Color(0.8, 0.8, 0.8),
			"outline": Color(0.1, 0.1, 0.1),
			"bp_match": Color(0.1, 0.1, 0.1),
			"bp_match_end": Color(0.1, 0.1, 0.1),
			"bp_mismatch": "gold",
		},
		"contig": {
			"edge": Color(0.1, 0.1, 0.1),
			"edge_hover": "gray",
			"edge_selected": "red",
			"fill": Color(0.8, 0.8, 0.8),
			"fill_hover": "white",
			"fill_selected": "yellow",
		},
		"text": Color(0.1, 0.1, 0.1),
		"genomes_bg": "white",
	},
}


var name = "Light"
var colours = get_theme()

func get_theme():
	return colour_themes[name]
	

func set_theme(new_name):
	name = new_name
	colours = get_theme()


func theme_names():
	return colour_themes.keys()
