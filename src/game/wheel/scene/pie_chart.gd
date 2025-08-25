@tool
class_name PieChart
extends Control

@export var center_offset: Vector2 = Vector2.ZERO
@export var colors: Dictionary[String, Color] = {}
@export var data: Dictionary[String, float] = {}
@export var radius: float = 100.0:
	set(value):
		radius = value
		queue_redraw()

var _slice_data: Array[Dictionary] = []

func _draw():
	if data.is_empty() and Engine.is_editor_hint():
		_draw_debug_outline()
		return
	
	var total = _calculate_total()
	var center = size / 2 + center_offset
	var current_angle = 0.0
	
	_slice_data.clear()
	
	for key in data.keys():
		var value = data.get(key, 0.0)
		var angle = (value / total) * TAU
		var color = colors.get(key, Color.WHITE)
		
		_draw_pie_slice(center, radius, current_angle, current_angle + angle, color)
		
		_slice_data.append({
			"name": key,
			"value": value,
			"start_angle": current_angle,
			"end_angle": current_angle + angle,
			"color": color
		})
		
		current_angle += angle


func _ready():
	pass


func get_slice_percentage(slice_name: String) -> float:
	if not data.has(slice_name):
		return 0.0
	
	var total = _calculate_total()
	if total == 0.0:
		return 0.0
	
	return (data.get(slice_name, 0.0) / total) * 100.0


func set_slice_color(slice_name: String, color: Color):
	colors[slice_name] = color
	queue_redraw()


func update_data(new_data: Dictionary[String, float], new_colors: Dictionary[String, Color] = {}):
	data = new_data
	if not new_colors.is_empty():
		colors = new_colors
	queue_redraw()


func _calculate_total() -> float:
	var total = 0.0
	for value in data.values():
		total += value
	return total


func _draw_pie_slice(center: Vector2, slice_radius: float, start_angle: float, end_angle: float, color: Color):
	var points = PackedVector2Array()
	points.append(center)
	
	var steps = max(8, int((end_angle - start_angle) / 0.1))
	for i in range(steps + 1):
		var angle = start_angle + (end_angle - start_angle) * i / steps
		points.append(center + Vector2(cos(angle), sin(angle)) * slice_radius)
	
	draw_colored_polygon(points, color)
	draw_arc(center, slice_radius, start_angle, end_angle, steps, Color.BLACK, 2.0)


func _draw_debug_outline():
	var center = size / 2 + center_offset
	draw_arc(center, radius, 0.0, TAU, 64, Color.RED, 2.0)
	
	# Draw radial lines for pie chart visualization
	var num_slices = 3
	for i in range(num_slices):
		var angle = (i * TAU) / num_slices
		var end_point = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, end_point, Color.RED, 1.0)