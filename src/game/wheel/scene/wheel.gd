extends Node2D

@onready var wheel_service: WheelService = Provider.inject(self, WheelService)

@export var resources: Array[WheelItemResource] = []

@onready var pie_chart: PieChart = %PieChart

func _ready() -> void:
	await Provider.ready()

	for resource in resources:
		wheel_service.add_item(resource)
	
	_update_pie_chart()

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
	
	for i in range(resources.size()):
		var resource = resources[i]
		var item_name = "Item %d" % (i + 1)
		data[item_name] = resource.weight
		colors[item_name] = random_colors[i % random_colors.size()]
	
	pie_chart.update_data(data, colors)
