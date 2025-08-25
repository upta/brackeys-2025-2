class_name WheelState
extends Node

signal item_added(item: WheelItemResource)
signal item_removed(item: WheelItemResource)
signal item_selected(item: WheelItemResource)
signal items_cleared()

var items: Array[WheelItemResource] = []
var selected_item: WheelItemResource:
	get:
		return selected_item
	set(value):
		selected_item = value
		if value != null:
			item_selected.emit(value)


func add_item(item: WheelItemResource) -> void:
	items.append(item)
	item_added.emit(item)


func clear_items() -> void:
	items.clear()
	items_cleared.emit()


func get_total_weight() -> float:
	var total_weight = 0.0

	for item in items:
		total_weight += item.weight

	return total_weight


func has_items() -> bool:
	return items.size() > 0


func remove_item(item: WheelItemResource) -> bool:
	var index = items.find(item)

	if index >= 0:
		items.remove_at(index)
		item_removed.emit(item)

		return true

	return false