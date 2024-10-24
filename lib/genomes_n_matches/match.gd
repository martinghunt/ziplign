extends StaticBody2D

class_name Match

signal mouse_in
signal mouse_out
signal match_selected


var match_width = 1
var mismatch_width = 2
var static_body_2d = StaticBody2D.new()
var coll_poly = CollisionPolygon2D.new()
var coll_poly2 = CollisionPolygon2D.new()
var poly = Polygon2D.new()
var poly2 = Polygon2D.new()
var outline1 = Line2D.new()
var outline2 = Line2D.new()
var top = 100
var bottom = 350
var outline_width = 0.75
var id
var selected = false
var hovering = false
var x_left_start1 = 0
var x_left_start2 = 0
var start1
var end1
var start2
var end2
var is_revcomp = false
var pc_id = 100.0
var x_zoom = 1
var length = 0
var visible_extra = 500
var alignment_lines = []
var fwd_col
var rev_col




func get_intersection(line1, line2):
	var d1 = line1.points[1] - line1.points[0]
	var d2 = line2.points[1] - line2.points[0]
	var t = (line2.points[0] - line1.points[0]).cross(d2) / d1.cross(d2)
	return line1.points[0] + t * d1


func _init(new_id, new_start1, new_end1, new_start2, new_end2, new_is_revcomp, new_pc_id, y_top=100, y_bottom=400):
	id = new_id
	start1 = new_start1 - 1
	end1 = new_end1 - 1
	start2 = new_start2 - 1
	end2 = new_end2 - 1
	top = y_top
	bottom = y_bottom
	length = max(end1 - start1, end2 - start2)
	is_revcomp = new_is_revcomp
	pc_id = new_pc_id
	outline1.width = outline_width
	outline1.default_color = Globals.theme.colours["blast_match"]["outline"]
	outline2.width = outline_width
	outline2.default_color = Globals.theme.colours["blast_match"]["outline"]
	var pc_light = min(0.6, 3 - 0.03 * pc_id)
	fwd_col = Color(Globals.theme.colours["blast_match"]["fwd"]).lightened(pc_light)
	rev_col = Color(Globals.theme.colours["blast_match"]["rev"]).lightened(pc_light)

	static_body_2d.set_pickable(true)
	static_body_2d.z_index = 0
	if is_revcomp:
		poly.color = rev_col
		poly2.color = rev_col
	else:
		poly.color = fwd_col

	set_polygon_coords()
	add_child(static_body_2d)
	static_body_2d.add_child(coll_poly)
	coll_poly.add_child(poly)
	if is_revcomp:
		static_body_2d.add_child(coll_poly2)
		coll_poly2.add_child(poly2)
	add_child(outline1)
	add_child(outline2)
	static_body_2d.mouse_entered.connect(_on_mouse_entered)
	static_body_2d.mouse_exited.connect(_on_mouse_exited)


func set_polygon_coords():
	if is_revcomp:
		if len(outline1.points) == 0:
			outline1.add_point(Vector2(x_left_start1 + x_zoom * start1, top))
			outline1.add_point(Vector2(x_left_start2 + x_zoom * end2, bottom))
			outline2.add_point(Vector2(x_left_start1 + x_zoom * end1, top))
			outline2.add_point(Vector2(x_left_start2 + x_zoom * start2, bottom))
		else:
			outline1.set_point_position(0, Vector2(x_left_start1 + x_zoom * start1, top))
			outline1.set_point_position(1, Vector2(x_left_start2 + x_zoom * end2, bottom))
			outline2.set_point_position(0, Vector2(x_left_start1 + x_zoom * end1, top))
			outline2.set_point_position(1, Vector2(x_left_start2 + x_zoom * start2, bottom))

		var inter = get_intersection(outline1, outline2)

		poly.polygon = [outline1.points[0], outline2.points[0], inter]
		poly2.polygon = [outline1.points[1], outline2.points[1], inter]
		coll_poly2.polygon = poly2.polygon
	else:
		if len(outline1.points) == 0:
			outline1.add_point(Vector2(x_left_start1 + x_zoom * start1, top))
			outline1.add_point(Vector2(x_left_start2 + x_zoom * start2, bottom))
			outline2.add_point(Vector2(x_left_start1 + x_zoom * end1, top))
			outline2.add_point(Vector2(x_left_start2 + x_zoom * end2, bottom))
		else:
			outline1.set_point_position(0, Vector2(x_left_start1 + x_zoom * start1, top))
			outline1.set_point_position(1, Vector2(x_left_start2 + x_zoom * start2, bottom))
			outline2.set_point_position(0, Vector2(x_left_start1 + x_zoom * end1, top))
			outline2.set_point_position(1, Vector2(x_left_start2 + x_zoom * end2, bottom))
		poly.polygon = [
			outline1.points[0],
			outline2.points[0],
			outline2.points[1],
			outline1.points[1],
		]

	coll_poly.polygon = poly.polygon
	update_visibility()


func update_visibility():
	delete_alignment_lines()
	if should_be_visible():
		show()
		if x_zoom >= Globals.zoom_to_show_bp:
			draw_alignment_lines()
	else:
		hide()
	
	
func is_visible_top_or_bottom(tolerance):
	return (-Globals.controls_width - tolerance <= poly.polygon[1].x \
			and poly.polygon[0].x <= Globals.controls_width + Globals.genomes_viewport_width + tolerance) \
		or (-Globals.controls_width -tolerance <= get_x_bottom_right_coords() \
			and get_x_bottom_left_coords() <= Globals.controls_width +Globals.genomes_viewport_width + tolerance)


func is_visible_top_and_bottom(tolerance):
	return -Globals.controls_width - tolerance <= poly.polygon[1].x \
		and poly.polygon[0].x <= Globals.controls_width + Globals.genomes_viewport_width + tolerance \
		and -Globals.controls_width - tolerance <= get_x_bottom_right_coords() \
		and get_x_bottom_left_coords() <= Globals.controls_width + Globals.genomes_viewport_width + tolerance


func should_be_visible():
	return length >= Globals.match_min_show_length \
	  and Globals.proj_data.blast_matches[id]["pc"] >= Globals.match_min_show_pc_id \
	  and is_visible_top_or_bottom(visible_extra)


func position_is_visible(x, tolerance):
	return -Globals.controls_width - tolerance <= x and x <= 2 * Globals.controls_width + Globals.genomes_viewport_width + tolerance
	

func draw_alignment_lines():
	delete_alignment_lines()
	if not is_visible_top_and_bottom(10):
		return
	var top_left = get_x_top_left_coords()
	var top_right = get_x_top_right_coords()
	var bottom_left = get_x_bottom_left_coords()
	var bottom_right = get_x_bottom_right_coords()
	var top_length_bp = end1 - start1
	var bottom_length_bp = end2 - start2
	var top_width = top_right - top_left
	var bottom_width = bottom_right - bottom_left
	var top_scale = top_width / top_length_bp
	var bottom_scale = bottom_width / bottom_length_bp

	
	for aln_data in Globals.proj_data.blast_matches[id]["aln_data"]:
		var top_start = top_left + aln_data[0] * top_scale
		var top_end = top_left + aln_data[1] * top_scale
		var bottom_start
		var bottom_end
		if is_revcomp:
			bottom_start = bottom_right - aln_data[3] * bottom_scale
			bottom_end = bottom_right - aln_data[2] * bottom_scale
		else:
			bottom_start = bottom_left + aln_data[2] * bottom_scale
			bottom_end = bottom_left + aln_data[3] * bottom_scale
		if top_end < -1 or bottom_end < -1 \
			or top_start > Globals.genomes_viewport_width + Globals.controls_width \
			or bottom_start > Globals.genomes_viewport_width + Globals.controls_width:
			continue
			
		if aln_data[4] == 0:
			var i = aln_data[0]
			while i <= aln_data[1]:
				var line_top = top_left + i * top_scale

				if position_is_visible(line_top, 10):
					var line_bottom
					if is_revcomp:
						line_bottom = bottom_right - (aln_data[2] + i - aln_data[0]) * bottom_scale
					else:
						line_bottom = bottom_left + (aln_data[2] + i - aln_data[0]) * bottom_scale
					if position_is_visible(line_bottom, 10):
						alignment_lines.append(Line2D.new())
						alignment_lines[-1].add_point(Vector2(line_top, top))
						alignment_lines[-1].add_point(Vector2(line_bottom, bottom))
						if i == aln_data[0] or i == aln_data[1]:
							alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_match_end"]
							alignment_lines[-1].width = mismatch_width
						else:
							alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_match"]
							alignment_lines[-1].width = match_width

						alignment_lines[-1].z_index = 5
						add_child(alignment_lines[-1])
				if i == aln_data[1]:
					break
				i = min(i + Globals.match_aln_step, aln_data[1])
		elif aln_data[4] == 1:
			if not position_is_visible(top_start, 10):
				continue

			var line_bottom
			if is_revcomp:
				line_bottom = bottom_right - aln_data[2] * bottom_scale
			else:
				line_bottom = bottom_left + aln_data[2] * bottom_scale
			if not position_is_visible(line_bottom, 10):
				continue
			alignment_lines.append(Line2D.new())
			alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_mismatch"]
			alignment_lines[-1].width = mismatch_width
			alignment_lines[-1].z_index = 5
			alignment_lines[-1].add_point(Vector2(top_start, top))
			alignment_lines[-1].add_point(Vector2(line_bottom, bottom))
			add_child(alignment_lines[-1])


func delete_alignment_lines():
	for a in alignment_lines:
		remove_child(a)
		a.free()
	alignment_lines.clear()


func get_x_top_left_coords():
	return poly.polygon[0].x


func get_x_top_right_coords():
	return poly.polygon[1].x


func get_x_bottom_left_coords():
	if is_revcomp:
		return poly2.polygon[1].x
	else:
		return poly.polygon[3].x


func get_x_bottom_right_coords():
	if is_revcomp:
		return poly2.polygon[0].x
	else:
		return poly.polygon[2].x


func set_x_zoom(zoom):
	x_zoom = zoom
	set_polygon_coords()


func set_top_bottom_coords(y_top, y_bottom):
	top = y_top
	bottom = y_bottom
	set_polygon_coords()


func set_top_x_left(x):
	x_left_start1 = x + Globals.controls_width
	set_polygon_coords()


func set_bottom_x_left(x):
	x_left_start2 = x + Globals.controls_width
	set_polygon_coords()


func set_x_lefts(new_top, new_bottom):
	x_left_start1 = new_top + Globals.controls_width
	x_left_start2 = new_bottom + Globals.controls_width
	set_polygon_coords()


func bring_to_top():
	static_body_2d.z_index = 1
	outline1.z_index = 1
	outline2.z_index = 1


func send_to_back():
	static_body_2d.z_index = 0
	outline1.z_index = 0
	outline2.z_index = 0


func select():
	selected = true
	bring_to_top()
	static_body_2d.z_index = 3
	outline1.z_index = 3
	outline2.z_index = 3
	poly.color = Globals.theme.colours["blast_match"]["selected"]
	if is_revcomp:
		poly2.color = Globals.theme.colours["blast_match"]["selected"]
	match_selected.emit(id)


func deselect():
	selected = false
	send_to_back()
	if hovering:
		if is_revcomp:
			poly.color = Globals.theme.colours["blast_match"]["rev_hover"]
			poly2.color = Globals.theme.colours["blast_match"]["rev_hover"]
		else:
			poly.color = Globals.theme.colours["blast_match"]["fwd_hover"]
	else:
		if is_revcomp:
			poly.color = rev_col
			poly2.color = rev_col
		else:
			poly.color = fwd_col


func _on_mouse_entered():
	hovering = true
	if selected:
		pass
	else:
		if is_revcomp:
			poly.color = Globals.theme.colours["blast_match"]["rev_hover"]
			poly2.color = Globals.theme.colours["blast_match"]["rev_hover"]
		else:
			poly.color = Globals.theme.colours["blast_match"]["fwd_hover"]
		bring_to_top()
	mouse_in.emit(id)


func _on_mouse_exited():
	hovering = false
	if not selected:
		if is_revcomp:
			poly.color = rev_col
			poly2.color = rev_col
		else:
			poly.color = fwd_col
		send_to_back()
	mouse_out.emit(id)
