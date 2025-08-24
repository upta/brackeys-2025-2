class_name WheelItem

@export var weight: float = 1.0

@warning_ignore("shadowed_variable")
func _init(weight: float = 1.0) -> void:
	self.weight = max(0.0, weight)