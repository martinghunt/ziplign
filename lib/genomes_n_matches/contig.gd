extends StaticBody2D

class_name Contig

signal mouse_in
signal mouse_out


var static_body_2d = StaticBody2D.new()
var coll_poly = CollisionPolygon2D.new()
var poly = Polygon2D.new()
var poly2 = Polygon2D.new()
var centerline = Line2D.new()
var leftvline = Line2D.new()
var rightvline = Line2D.new()
var centerline_width = 5
var centerline_width_zoomed = 2
var top = 5
var bottom = 30
var middle = 0.5 * (top + bottom)
var edge_width = 4
var id
var selected = false
var hovering = false
var x_offset = 0
var x_start
var x_end
var length_in_bp
var fill_colour = Color("gray")
var fill_hover_colour = Color("light_gray")
var fill_select_colour = Color("pink")
var edge_colour = Color("black")
var edge_hover_colour = Color("gray")
var edge_select_colour = Color("red")


func _init(new_id, new_x_start, new_x_end, new_top, new_bottom, bp_length):
	id = new_id
	top = new_top
	bottom = new_bottom
	middle = 0.5 * (top + bottom)
	static_body_2d.set_pickable(true)
	poly.color = fill_colour
	centerline.default_color = edge_colour
	centerline.add_point(Vector2(0, 0))
	centerline.add_point(Vector2(0, 0))
	set_start_end(new_x_start, new_x_end)
	add_child(static_body_2d)
	static_body_2d.add_child(coll_poly)
	coll_poly.add_child(poly)
	coll_poly.add_child(centerline)
	static_body_2d.mouse_entered.connect(_on_mouse_entered)
	static_body_2d.mouse_exited.connect(_on_mouse_exited)
	length_in_bp = bp_length



func shift(x_move):
	x_offset += x_move
	for i in range(3):
		poly.polygon[i][0] += x_move
		poly2.polygon[i][0] += x_move
		coll_poly.polygon[i][0] += x_move


func set_polygons_coords():
	poly.polygon = [
		Vector2(x_start, top),
		Vector2(x_end, top),
		Vector2(x_end, bottom),
		Vector2(x_start, bottom),
	]
	coll_poly.polygon = poly.polygon
	centerline.set_point_position(0, Vector2(x_start, middle))
	centerline.set_point_position(1, Vector2(x_end, middle))



func set_zoomed_view(turn_on):
	if turn_on:
		centerline.width = centerline_width_zoomed
		poly.hide()
	else:
		centerline.width = centerline_width
		poly.show()


func set_start_end(new_start, new_end):
	x_start = new_start
	x_end = new_end
	set_polygons_coords()

func select():
	selected = true
	poly.color = fill_select_colour
	centerline.default_color = edge_select_colour


func deselect():
	selected = false
	if hovering:
		centerline.default_color = edge_hover_colour
	else:
		centerline.default_color = edge_colour



func _on_mouse_entered():
	hovering = true
	if selected:
		poly.color = fill_hover_colour
		pass
	else:
		#poly2.color = fill_hover_colour
		centerline.default_color = edge_hover_colour

	mouse_in.emit(id)


func _on_mouse_exited():
	hovering = false
	poly.color = fill_colour
	centerline.default_color = edge_colour
	if not selected:
		#poly2.color = fill_colour
		pass
	mouse_out.emit(id)
