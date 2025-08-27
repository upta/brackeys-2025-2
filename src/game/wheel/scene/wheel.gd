extends Node2D

@onready var checkpoint_service: CheckpointService = Provider.inject(self, CheckpointService)
@onready var wheel_service: WheelService = Provider.inject(self, WheelService)

@export var resources: Array[WheelItemResource] = []

@onready var pie_chart: PieChart = %PieChart
@onready var spin_button: TextureButton = %SpinButton

func _ready() -> void:
	await Provider.ready()

	spin_button.pressed.connect(_on_spin_button_pressed)
	$SpinButton.pressed.connect(_on_spin_button_pressed)
	checkpoint_service.state.checkpoint_state_changed.connect(_on_checkpoint_state_changed)
	
	wheel_service.state.item_added.connect(_on_wheel_item_added)
	wheel_service.state.item_removed.connect(_on_wheel_item_removed)
	wheel_service.state.items_cleared.connect(_on_wheel_items_cleared)

	for resource in resources:
		wheel_service.add_item(resource)
	
	_update_pie_chart()
	_update_spin_button_visibility()

func _update_pie_chart() -> void:
	var data: Dictionary[String, float] = {}
	var colors: Dictionary[String, Color] = {}
	var random_colors = [
		Color.RED,
		Color.GREEN,
		Color.BLUE,
		Color.YELLOW,
		Color.MAGENTA,
		Color.CYAN,
		Color.ORANGE,
		Color.PURPLE,
		Color.PINK,
		Color.LIME_GREEN
	]
	
	var items = wheel_service.state.items
	for i in range(items.size()):
		var item = items[i]
		var display_name = item.name if item.name != "" else "Item %d" % (i + 1)
		var unique_key = "%s (#%d)" % [display_name, i]
		data[unique_key] = item.weight
		colors[unique_key] = random_colors[i % random_colors.size()]
	
	pie_chart.update_data(data, colors)


func _on_spin_button_pressed() -> void:
	if not wheel_service.state.has_items():
		push_warning("Cannot spin wheel with no items")
		return
	
	spin_button.disabled = true
	
	var selected_item = wheel_service.get_random_item()
	if selected_item == null:
		spin_button.disabled = false
		return
	
	var target_angle = _calculate_target_angle_for_item(selected_item)
	var full_rotations = 3.0 * TAU
	var current_rotation = pie_chart.rotation
	var total_rotation = current_rotation + full_rotations + target_angle
	
	var tween = create_tween()
	tween.tween_method(_rotate_pie_chart, current_rotation, total_rotation, 3.0)
	tween.tween_callback(_on_spin_complete.bind(selected_item))


func _calculate_target_angle_for_item(target_item: WheelItemResource) -> float:
	var total_weight = wheel_service.state.get_total_weight()
	var accumulated_weight = 0.0
	var target_item_index = -1
	var items = wheel_service.state.items
	
	for i in range(items.size()):
		if items[i] == target_item:
			target_item_index = i
			break
		accumulated_weight += items[i].weight
	
	if target_item_index == -1:
		return 0.0
	
	var slice_start_angle = (accumulated_weight / total_weight) * TAU
	var slice_end_angle = ((accumulated_weight + target_item.weight) / total_weight) * TAU
	var random_position = randf_range(0.05, 0.95)
	var slice_target_angle = slice_start_angle + (slice_end_angle - slice_start_angle) * random_position
	
	var target_angle_from_zero = TAU - slice_target_angle
	var current_rotation_normalized = fmod(pie_chart.rotation, TAU)
	if current_rotation_normalized < 0:
		current_rotation_normalized += TAU
	
	return target_angle_from_zero - current_rotation_normalized


func _rotate_pie_chart(angle: float) -> void:
	pie_chart.rotation = angle


func _on_spin_complete(selected_item: WheelItemResource) -> void:
	prints("Selected: ", selected_item)
	wheel_service.select_item(selected_item)
	spin_button.disabled = false

	checkpoint_service.step()
	

func _on_checkpoint_state_changed(_is_at_checkpoint: bool) -> void:
	_update_spin_button_visibility()


func _update_spin_button_visibility() -> void:
	spin_button.visible = not checkpoint_service.state.is_at_checkpoint()


func _on_wheel_item_added(_item: WheelItemResource) -> void:
	_update_pie_chart()


func _on_wheel_item_removed(_item: WheelItemResource) -> void:
	_update_pie_chart()


func _on_wheel_items_cleared() -> void:
	_update_pie_chart()
