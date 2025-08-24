class_name WheelState
extends Node

signal item_added(item: WheelItem)
signal item_removed(item: WheelItem)
signal item_selected(item: WheelItem)
signal items_cleared()

var items: Array[WheelItem] = []
var selected_item: WheelItem:
	get:
		return selected_item
	set(value):
		selected_item = value
		if value != null:
			item_selected.emit(value)


func add_item(item: WheelItem) -> void:
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


func remove_item(item: WheelItem) -> bool:
	var index = items.find(item)

	if index >= 0:
		items.remove_at(index)
		item_removed.emit(item)

		return true

	return false