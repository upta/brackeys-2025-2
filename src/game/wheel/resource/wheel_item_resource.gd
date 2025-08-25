class_name WheelItemResource
extends Resource

@export var name: String = ""
@export var weight: float = 1.0

@warning_ignore("shadowed_variable")
func _init(weight: float = 1.0) -> void:
	self.weight = max(0.0, weight)


func apply() -> void:
	push_error("WheelItemResource.apply() must be overridden in child classes")


func _to_string() -> String:
	return "WheelItemResource(name=%s, weight=%s)" % [name, weight]