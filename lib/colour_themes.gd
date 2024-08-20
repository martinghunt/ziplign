class_name ColourThemes

var colour_themes = {
	"classic": {
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
		"text": "black",
		"genomes_bg": "white"
	},
	"dark": {
		"blast_match": {
			"fwd": "dark_red",
			"rev": "midnight_blue",
			"fwd_hover": "web_purple",
			"rev_hover": "steel_blue",
			"selected": "black",
			"outline": "black",
			"bp_match": "black",
			"bp_match_end": "black",
			"bp_mismatch": "slate_gray",
		},
		"text": "white_smoke",
		"genomes_bg": "dim_gray",
	},
	"light": {
		"blast_match": {
			"fwd": "green",
			"rev": "orange",
			"fwd_hover": "light_green",
			"rev_hover": "yellow",
			"selected": "white",
			"outline": "slate_gray",
			"bp_match": "black",
			"bp_match_end": "black",
			"bp_mismatch": "red",
		},
		"text": "black",
		"genomes_bg": "slate_gray",
	}
}


var name = "classic"
var colours = get_theme()

func get_theme():
	return colour_themes[name]
	

func set_theme(new_name):
	name = new_name
	colours = get_theme()


func theme_names():
	return colour_themes.keys()
