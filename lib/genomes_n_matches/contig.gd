extends StaticBody2D

class_name Contig

signal mouse_in
signal mouse_out

const AnnotFeatureClass = preload("res://lib/annot_feature.gd")

var static_body_2d = StaticBody2D.new()
var coll_poly = CollisionPolygon2D.new()
var poly = Polygon2D.new()
var centerline = Line2D.new()
var leftvline = Line2D.new()
var rightvline = Line2D.new()
var top_or_bottom
var vline_width = 2
var centerline_width = 1
var centerline_width_zoomed = 1
var top = 5
var bottom = 30
var gene_fwd_top = 9
var gene_fwd_bottom = 17
var gene_rev_top = 21
var gene_rev_bottom = 28
var middle = 0.5 * (top + bottom)
var centerline_y = middle
var id
var selected = false
var hovering = false
var x_offset = 0
var x_start
var x_end
var length_in_bp
var fill_color
var annot_polys = []
var gff_features = []


func set_gene_top_bottom(zoomed: bool):
	if zoomed:
		gene_fwd_top = top + 5
		gene_fwd_bottom = top + 0.6 * (middle - top)
		gene_rev_top = middle + 0.4 * (bottom - middle)
		gene_rev_bottom = bottom - 5
	else:
		gene_fwd_top = top + 0.15 * (middle - top)
		gene_fwd_bottom = top + 0.85 * (middle - top)
		gene_rev_top = middle + 0.15 * (bottom - middle)
		gene_rev_bottom = middle + 0.85 * (bottom - middle)


func _init(new_id, new_top_or_bottom, new_x_start, new_x_end, new_top, new_bottom, bp_length, annotation):
	id = new_id
	top_or_bottom = new_top_or_bottom
	top = new_top
	bottom = new_bottom
	middle = 0.5 * (top + bottom)
	set_gene_top_bottom(false)
	centerline_y = middle
	static_body_2d.set_pickable(true)
	if id % 2 == 0:
		fill_color = Globals.theme.colours["contig"]["fill"]
	else:
		fill_color = Globals.theme.colours["contig"]["fill_alt"]
	poly.color = fill_color
	centerline.default_color = Globals.theme.colours["contig"]["edge"]
	centerline.add_point(Vector2(0, centerline_y))
	centerline.add_point(Vector2(0, centerline_y))
	centerline.width = centerline_width
	leftvline.default_color = Globals.theme.colours["contig"]["edge"]
	leftvline.add_point(Vector2(0, 0))
	leftvline.add_point(Vector2(0, 0))
	leftvline.width = vline_width
	rightvline.default_color = Globals.theme.colours["contig"]["edge"]
	rightvline.add_point(Vector2(0, 0))
	rightvline.add_point(Vector2(0, 0))
	rightvline.width = vline_width
	set_start_end(new_x_start, new_x_end)
	add_child(static_body_2d)
	static_body_2d.add_child(coll_poly)
	coll_poly.add_child(poly)
	coll_poly.add_child(centerline)
	coll_poly.add_child(leftvline)
	coll_poly.add_child(rightvline)
	length_in_bp = bp_length
	# comment out for now to stop doing anything on mouse hover
	# or selecting, because haven't implemented doing anything with
	# selected contig
	static_body_2d.mouse_entered.connect(_on_mouse_entered)
	static_body_2d.mouse_exited.connect(_on_mouse_exited)
	gff_features = annotation
	for feature in gff_features:
		if feature[0] == 0 and feature[1] == length_in_bp - 1:
			continue
		var f_top = gene_fwd_top
		var f_bot = gene_fwd_bottom
		if feature[3]: # is reverse
			f_top = gene_rev_top
			f_bot = gene_rev_bottom
		annot_polys.append(AnnotFeatureClass.new(feature, f_top, f_bot, self))
		add_child(annot_polys[-1])

	annot_polys.sort_custom(func(a, b): return a.gff_data[0] < b.gff_data[0])


func name():
	return Globals.proj_data.genome_seqs[top_or_bottom]["names"][id]

func shift(x_move):
	x_offset += x_move
	for i in range(3):
		poly.polygon[i][0] += x_move
		coll_poly.polygon[i][0] += x_move


func set_polygons_coords():
	poly.polygon = [
		Vector2(x_start, top),
		Vector2(x_end, top),
		Vector2(x_end, bottom),
		Vector2(x_start, bottom),
	]
	coll_poly.polygon = poly.polygon
	centerline.set_point_position(0, Vector2(x_start, centerline_y))
	centerline.set_point_position(1, Vector2(x_end, centerline_y))
	leftvline.set_point_position(0, Vector2(x_start, top))
	leftvline.set_point_position(1, Vector2(x_start, bottom))
	rightvline.set_point_position(0, Vector2(x_end, top))
	rightvline.set_point_position(1, Vector2(x_end, bottom))
	for x in annot_polys:
		x.set_polygon_coords()



func set_zoomed_view(turn_on):
	if turn_on:
		centerline.width = centerline_width_zoomed
		if top_or_bottom == "top":
			centerline_y = top
		else:
			centerline_y = bottom
		leftvline.hide()
		rightvline.hide()
		poly.hide()
	else:
		centerline.width = centerline_width
		centerline_y = middle
		leftvline.show()
		rightvline.show()
		poly.show()

	centerline.set_point_position(0, Vector2(x_start, centerline_y))
	centerline.set_point_position(1, Vector2(x_end, centerline_y))

	set_gene_top_bottom(turn_on)
	for x in annot_polys:
		if x.is_rev():
			x.set_top_and_bottom(gene_rev_top, gene_rev_bottom)
		else:
			x.set_top_and_bottom(gene_fwd_top, gene_fwd_bottom)


func find_first_annot_before_pos(pos):
	if len(annot_polys) == 0 \
		or annot_polys[0].poly.polygon[0].x > pos:
		return -1
	if annot_polys[-1].poly.polygon[0].x < pos:
		return len(annot_polys) - 1
	var i = 0
	var j = len(annot_polys) - 1

	while i < j:
		var k = ceili(0.5 *(i + j))
		if annot_polys[k].poly.polygon[0].x > pos:
			if k > 0 and annot_polys[k-1].poly.polygon[0].x <= pos:
				return k - 1
			j = k
		elif annot_polys[k].poly.polygon[0].x == pos:
			return k
		else:
			i = k

	return -1


func set_start_end(new_start, new_end):
	x_start = new_start
	x_end = new_end
	set_polygons_coords()

func select():
	selected = true
	poly.color = Globals.theme.colours["contig"]["fill_selected"]
	centerline.default_color = Globals.theme.colours["contig"]["edge_selected"]
	leftvline.default_color = Globals.theme.colours["contig"]["edge_selected"]
	rightvline.default_color = Globals.theme.colours["contig"]["edge_selected"]

func deselect():
	selected = false
	if hovering:
		poly.color = Globals.theme.colours["contig"]["fill_hover"]
		centerline.default_color = Globals.theme.colours["contig"]["edge_hover"]
		leftvline.default_color = Globals.theme.colours["contig"]["edge_hover"]
		rightvline.default_color = Globals.theme.colours["contig"]["edge_hover"]
	else:
		poly.color = fill_color
		centerline.default_color = Globals.theme.colours["contig"]["edge"]
		leftvline.default_color = Globals.theme.colours["contig"]["edge"]
		rightvline.default_color = Globals.theme.colours["contig"]["edge"]


func update_annot_visibility_in_range(start, end, x_zoom):
	if len(annot_polys) == 0 \
	or start > end:
		return

	var i = find_first_annot_before_pos(end)
	while i >= 0 and annot_polys[i].poly.polygon[1].x > start - 500:
		annot_polys[i].set_visibility(x_zoom)
		i -= 1


func set_annot_visibility(zoom):
	for x in annot_polys:
		x.set_visibility(zoom)


func _on_mouse_entered():
	hovering = true
	if selected:
		pass
		#poly.color = Globals.theme.colours["contig"]["fill_hover"]
	else:
		centerline.default_color = Globals.theme.colours["contig"]["edge_hover"]
		poly.color = Globals.theme.colours["contig"]["fill_hover"]

	mouse_in.emit(id)


func _on_mouse_exited():
	hovering = false
	if selected:
		poly.color = Globals.theme.colours["contig"]["fill_selected"]
		centerline.default_color = Globals.theme.colours["contig"]["edge_selected"]
	else:
		poly.color = fill_color
		centerline.default_color = Globals.theme.colours["contig"]["edge"]
	mouse_out.emit(id)
