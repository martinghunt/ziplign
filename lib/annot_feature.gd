extends StaticBody2D

class_name AnnotFeature

var static_body_2d = StaticBody2D.new()
var coll_poly = CollisionPolygon2D.new()
var poly = Polygon2D.new()
var outline = Line2D.new()
var top = 50
var bottom = 100
var outline_width = 1.5
var gff_data = []
var parent_ctg
var name_label = Label.new()


func set_top_and_bottom(new_top, new_bottom):
	top = new_top
	bottom = new_bottom
	if "Parent" in gff_data[4] or "parent" in gff_data[4]:
		top += 2
		bottom -= 2
	set_polygon_coords()

func is_rev():
	return gff_data[3]


func set_visibility(zoom):
	if zoom > Globals.zoom_to_show_annot_all \
		or (zoom > Globals.zoom_to_show_annot_500 and (gff_data[1] - gff_data[0]) >= 500) \
		or (zoom > Globals.zoom_to_show_annot_1k and (gff_data[1] - gff_data[0]) >= 1000) \
		or (zoom > Globals.zoom_to_show_annot_2k and (gff_data[1] - gff_data[0]) >= 2000):
		show()
	else:
		hide()


func set_polygon_coords():
	if len(outline.points) == 0:
		outline.add_point(Vector2(-(0.5 * outline_width) + parent_ctg.x_start + (parent_ctg.x_end - parent_ctg.x_start) * gff_data[0] / parent_ctg.length_in_bp, top))
		outline.add_point(Vector2(-(0.5 * outline_width) + parent_ctg.x_start + (parent_ctg.x_end - parent_ctg.x_start) * gff_data[1] / parent_ctg.length_in_bp, top))
		outline.add_point(Vector2(outline.points[1].x, bottom))
		outline.add_point(Vector2(outline.points[0].x, bottom))
		outline.add_point(outline.points[0])
	else:
		outline.set_point_position(0, Vector2(-(0.5 * outline_width) + parent_ctg.x_start + (parent_ctg.x_end - parent_ctg.x_start) * gff_data[0] / parent_ctg.length_in_bp, top))
		outline.set_point_position(1, Vector2(-(0.5 * outline_width) + parent_ctg.x_start + (parent_ctg.x_end - parent_ctg.x_start) * gff_data[1] / parent_ctg.length_in_bp, top))
		outline.set_point_position(2, Vector2(outline.points[1].x, bottom))
		outline.set_point_position(3, Vector2(outline.points[0].x, bottom))
		outline.set_point_position(4, outline.points[0])
		
	poly.polygon = outline.points.slice(0, 4)
	coll_poly.polygon = poly.polygon
	#name_label.position = outline.points[0]
	name_label.position = Vector2(outline.points[0].x + 1, outline.points[0].y + 1)
	name_label.set_size(Vector2(outline.points[1].x - outline.points[0].x - 1, outline.points[2].y - outline.points[0].y - 1))
	name_label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	name_label.clip_text = true


func _init(gff_data_list, new_top, new_bottom, parent_contig):
	gff_data = gff_data_list
	top = new_top
	bottom = new_bottom
	parent_ctg = parent_contig
	if "Parent" in gff_data[4] or "parent" in gff_data[4]:
		top += 2
		bottom -= 2
		outline_width = 1
		
	outline.width = outline_width
	outline.default_color = Globals.theme.colours["ui"]["text"]
	poly.color = Globals.theme.colours["ui"]["panel_bg"]

	name_label.add_theme_color_override("font_color", Globals.theme.colours["text"])
	name_label.add_theme_font_override("font", Globals.fonts["dejavu"])
	name_label.add_theme_font_size_override("font_size", Globals.font_annot_size)
	for k in ["Name", "name", "ID"]:
		name_label.text = gff_data[4].get(k, "")
		if name_label.text != "":
			break
	if name_label.text == "":
		name_label.text = "UNKNOWN"

	set_polygon_coords()
	add_child(static_body_2d)
	static_body_2d.add_child(coll_poly)
	coll_poly.add_child(poly)
	static_body_2d.add_child(outline)
	add_child(name_label)
	hide()
