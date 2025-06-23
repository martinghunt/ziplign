extends StaticBody2D

class_name Match

signal mouse_in
signal mouse_out
signal match_selected


var static_body_2d: StaticBody2D
var coll_poly: CollisionPolygon2D
var coll_poly2: CollisionPolygon2D
var poly: Polygon2D
var poly2: Polygon2D
var outline1: Line2D
var outline2: Line2D
var blast_id
var blast_hit
var selected = false
var hovering = false
var start1
var end1
var start2
var end2
var alignment_lines = []
var is_currently_visible = false
var canvas_top_left_x: float
var canvas_top_right_x: float
var canvas_bot_left_x: float
var canvas_bot_right_x: float



func get_intersection(line1, line2):
	var d1 = line1.points[1] - line1.points[0]
	var d2 = line2.points[1] - line2.points[0]
	var t = (line2.points[0] - line1.points[0]).cross(d2) / d1.cross(d2)
	return line1.points[0] + t * d1


func _init(new_blast_id, new_start1, new_end1, new_start2, new_end2):
	blast_id = new_blast_id
	blast_hit = Globals.proj_data.blast_hits[blast_id]
	start1 = new_start1 - 1
	end1 = new_end1 - 1
	start2 = new_start2 - 1
	end2 = new_end2 - 1
	update_canvas_coords()
	
	static_body_2d = StaticBody2D.new()
	coll_poly = CollisionPolygon2D.new()
	poly = Polygon2D.new()
	outline1 = Line2D.new()
	outline2 = Line2D.new()
	
	if is_rev():
		coll_poly2 = CollisionPolygon2D.new()
		poly2 = Polygon2D.new()

	
	outline1.width = Globals.match_outline_width
	outline1.default_color = Globals.theme.colours["blast_match"]["outline"]
	outline2.width = Globals.match_outline_width
	outline2.default_color = Globals.theme.colours["blast_match"]["outline"]

	static_body_2d.set_pickable(true)
	static_body_2d.z_index = 0
	if is_rev():
		poly.color = rev_col()
		poly2.color = rev_col()
	else:
		poly.color = fwd_col()

	static_body_2d.add_child(coll_poly)
	coll_poly.add_child(poly)
	if is_rev():
		static_body_2d.add_child(coll_poly2)
		coll_poly2.add_child(poly2)
	add_child(static_body_2d)
	add_child(outline1)
	add_child(outline2)
	is_currently_visible = false
	static_body_2d.mouse_entered.connect(_on_mouse_entered)
	static_body_2d.mouse_exited.connect(_on_mouse_exited)


func is_rev():
	return blast_hit.is_rev


func pc_id():
	return blast_hit.pcid


func length():
	return max(end1 - start1, end2 - start2)


func fwd_col():
	return Color(Globals.theme.colours["blast_match"]["fwd"]).lightened(min(0.6, 3 - 0.03 * pc_id()))


func rev_col():
	return Color(Globals.theme.colours["blast_match"]["rev"]).lightened(min(0.6, 3 - 0.03 * pc_id()))


func update_canvas_coords():
	canvas_top_left_x = Globals.controls_width + Globals.top_x_left + Globals.x_zoom * start1
	canvas_top_right_x = Globals.controls_width + Globals.top_x_left + Globals.x_zoom * end1
	canvas_bot_left_x = Globals.controls_width + Globals.bottom_x_left + Globals.x_zoom * start2
	canvas_bot_right_x = Globals.controls_width + Globals.bottom_x_left + Globals.x_zoom * end2


func update_outline_coords():
	if is_rev():
		outline1.set_point_position(0, Vector2(canvas_top_left_x, Globals.matches_y_top))
		outline1.set_point_position(1, Vector2(canvas_bot_right_x, Globals.matches_y_bottom))
		outline2.set_point_position(0, Vector2(canvas_top_right_x, Globals.matches_y_top))
		outline2.set_point_position(1, Vector2(canvas_bot_left_x, Globals.matches_y_bottom))
	else:
		outline1.set_point_position(0, Vector2(canvas_top_left_x, Globals.matches_y_top))
		outline1.set_point_position(1, Vector2(canvas_bot_left_x, Globals.matches_y_bottom))
		outline2.set_point_position(0, Vector2(canvas_top_right_x, Globals.matches_y_top))
		outline2.set_point_position(1, Vector2(canvas_bot_right_x, Globals.matches_y_bottom))


func update_polygons():
	if is_rev():
		var inter = get_intersection(outline1, outline2)
		poly.polygon = [outline1.points[0], outline2.points[0], inter]
		poly2.polygon = [outline1.points[1], outline2.points[1], inter]
		coll_poly2.polygon = poly2.polygon
	else:
		poly.polygon = [
			outline1.points[0],
			outline2.points[0],
			outline2.points[1],
			outline1.points[1],
		]
	coll_poly.polygon = poly.polygon


func update_view():
	update_outline_coords()
	update_polygons()



func make_visible():
	if is_currently_visible:
		return
	
	if is_rev():
		outline1.add_point(Vector2(canvas_top_left_x, Globals.matches_y_top))
		outline1.add_point(Vector2(canvas_bot_right_x, Globals.matches_y_bottom))
		outline2.add_point(Vector2(canvas_top_right_x, Globals.matches_y_top))
		outline2.add_point(Vector2(canvas_bot_left_x, Globals.matches_y_bottom))
	else:
		outline1.add_point(Vector2(canvas_top_left_x, Globals.matches_y_top))
		outline1.add_point(Vector2(canvas_bot_left_x, Globals.matches_y_bottom))
		outline2.add_point(Vector2(canvas_top_right_x, Globals.matches_y_top))
		outline2.add_point(Vector2(canvas_bot_right_x, Globals.matches_y_bottom))

	update_polygons()
	is_currently_visible = true
	show()



func make_invisible():
	delete_alignment_lines()
	if is_currently_visible:
		outline1.clear_points()
		outline2.clear_points()
		poly.polygon.clear()
		coll_poly.polygon.clear()
		if is_rev():
			poly2.polygon.clear()
			coll_poly2.polygon.clear()
		is_currently_visible = false
		hide()


func update_visibility():
	if should_be_visible():
		delete_alignment_lines()
		if is_currently_visible:
			update_view()
		else:
			make_visible()
		if Globals.x_zoom >= Globals.zoom_to_show_bp:
			draw_alignment_lines()
	else:
		make_invisible()
	
	
func is_visible_top_or_bottom(tolerance):
	return (-Globals.controls_width - tolerance <= canvas_top_right_x \
			and canvas_top_left_x <= Globals.controls_width + Globals.genomes_viewport_width + tolerance) \
		or (-Globals.controls_width -tolerance <= canvas_bot_right_x \
			and canvas_bot_left_x <= Globals.controls_width +Globals.genomes_viewport_width + tolerance)


func is_visible_top_and_bottom(tolerance):
	return -Globals.controls_width - tolerance <= canvas_top_right_x \
		and canvas_top_left_x <= Globals.controls_width + Globals.genomes_viewport_width + tolerance \
		and -Globals.controls_width - tolerance <= canvas_bot_right_x \
		and canvas_bot_left_x <= Globals.controls_width + Globals.genomes_viewport_width + tolerance


func should_be_visible():
	return Globals.match_min_show_length <= length() \
	  and length() <= Globals.match_max_show_length \
	  and pc_id() >= Globals.match_min_show_pc_id \
	  and is_visible_top_or_bottom(Globals.matches_visible_extra)


func position_is_visible(x, tolerance):
	return -Globals.controls_width - tolerance <= x and x <= 2 * Globals.controls_width + Globals.genomes_viewport_width + tolerance
	

func draw_alignment_lines():
	delete_alignment_lines()
	if not is_currently_visible:
		return

	var top_length_bp = end1 - start1
	var bottom_length_bp = end2 - start2
	var top_width = canvas_top_right_x - canvas_top_left_x
	var bottom_width = canvas_bot_right_x - canvas_bot_left_x
	var top_scale = top_width / top_length_bp
	var bottom_scale = bottom_width / bottom_length_bp
#
	
	for aln_i in range(0, len(blast_hit.aln_data), 5):
		var top_start = canvas_top_left_x + blast_hit.aln_data[aln_i] * top_scale
		var top_end = canvas_top_left_x + blast_hit.aln_data[aln_i+1] * top_scale
		if top_end < -1 or top_start > Globals.genomes_viewport_width + Globals.controls_width:
			continue
		var bottom_start
		var bottom_end
		if is_rev():
			bottom_start = canvas_bot_right_x - blast_hit.aln_data[aln_i+3] * bottom_scale
			bottom_end = canvas_bot_right_x - blast_hit.aln_data[aln_i+2] * bottom_scale
		else:
			bottom_start = canvas_bot_left_x + blast_hit.aln_data[aln_i+2] * bottom_scale
			bottom_end = canvas_bot_left_x + blast_hit.aln_data[aln_i+3] * bottom_scale
		if bottom_end < -1 or bottom_start > Globals.genomes_viewport_width + Globals.controls_width:
			continue
			
		if blast_hit.aln_data[aln_i+4] == 0:
			var i = blast_hit.aln_data[aln_i]
			while i <= blast_hit.aln_data[aln_i+1]:
				var line_top = canvas_top_left_x + i * top_scale

				if position_is_visible(line_top, 10):
					var line_bottom
					if is_rev():
						line_bottom = canvas_bot_right_x - (blast_hit.aln_data[aln_i+2] + i - blast_hit.aln_data[aln_i]) * bottom_scale
					else:
						line_bottom = canvas_bot_left_x + (blast_hit.aln_data[aln_i+2] + i - blast_hit.aln_data[aln_i]) * bottom_scale
					if position_is_visible(line_bottom, 10):
						alignment_lines.append(Line2D.new())
						alignment_lines[-1].add_point(Vector2(line_top, Globals.matches_y_top))
						alignment_lines[-1].add_point(Vector2(line_bottom, Globals.matches_y_bottom))
						if i == blast_hit.aln_data[aln_i] or i == blast_hit.aln_data[aln_i+1]:
							alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_match_end"]
							alignment_lines[-1].width = Globals.match_aln_mismatch_width
						else:
							alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_match"]
							alignment_lines[-1].width = Globals.match_aln_match_width

						alignment_lines[-1].z_index = 5
						add_child(alignment_lines[-1])
				if i == blast_hit.aln_data[aln_i+1]:
					break
				i = min(i + Globals.match_aln_step, blast_hit.aln_data[aln_i+1])
		elif blast_hit.aln_data[aln_i+4] == 1:
			if not position_is_visible(top_start, 10):
				continue

			var line_bottom
			if is_rev():
				line_bottom = canvas_bot_right_x - blast_hit.aln_data[aln_i+2] * bottom_scale
			else:
				line_bottom = canvas_bot_left_x + blast_hit.aln_data[aln_i+2] * bottom_scale
			if not position_is_visible(line_bottom, 10):
				continue
			alignment_lines.append(Line2D.new())
			alignment_lines[-1].default_color = Globals.theme.colours["blast_match"]["bp_mismatch"]
			alignment_lines[-1].width = Globals.match_aln_mismatch_width
			alignment_lines[-1].z_index = 5
			alignment_lines[-1].add_point(Vector2(top_start, Globals.matches_y_top))
			alignment_lines[-1].add_point(Vector2(line_bottom, Globals.matches_y_bottom))
			add_child(alignment_lines[-1])


func delete_alignment_lines():
	for a in alignment_lines:
		remove_child(a)
		a.free()
	alignment_lines.clear()


func intersects_range(left, right, is_top):
	if is_top:
		return right >= canvas_top_left_x and left <= canvas_top_right_x
	else:
		return right >= canvas_bot_left_x and left <= canvas_bot_right_x


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
	if is_rev():
		poly2.color = Globals.theme.colours["blast_match"]["selected"]
	match_selected.emit(blast_id)


func deselect():
	selected = false
	send_to_back()
	if hovering:
		if is_rev():
			poly.color = Globals.theme.colours["blast_match"]["rev_hover"]
			poly2.color = Globals.theme.colours["blast_match"]["rev_hover"]
		else:
			poly.color = Globals.theme.colours["blast_match"]["fwd_hover"]
	else:
		if is_rev():
			poly.color = rev_col()
			poly2.color = rev_col()
		else:
			poly.color = fwd_col()


func _on_mouse_entered():
	hovering = true
	if selected:
		pass
	else:
		if is_rev():
			poly.color = Globals.theme.colours["blast_match"]["rev_hover"]
			poly2.color = Globals.theme.colours["blast_match"]["rev_hover"]
		else:
			poly.color = Globals.theme.colours["blast_match"]["fwd_hover"]
		bring_to_top()
	mouse_in.emit(blast_id)


func _on_mouse_exited():
	hovering = false
	if not selected:
		if is_rev():
			poly.color = rev_col()
			poly2.color = rev_col()
		else:
			poly.color = fwd_col()
		send_to_back()
	mouse_out.emit(blast_id)
