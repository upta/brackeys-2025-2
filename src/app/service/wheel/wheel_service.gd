class_name WheelService
extends Node

@onready var state: WheelState = Provider.inject(self, WheelState)


func add_item(item: WheelItem) -> void:
	state.add_item(item)


func clear_items() -> void:
	state.clear_items()


func remove_item(item: WheelItem) -> bool:
	return state.remove_item(item)


func select_random_item() -> WheelItem:
	if !state.has_items():
		push_error("Cannot select from empty wheel")
		return null

	var total_weight = state.get_total_weight()
	if total_weight <= 0.0:
		push_error("Total weight must be greater than 0")
		return null

	var random_value = randf() * total_weight
	var accumulated_weight = 0.0

	for item in state.items:
		accumulated_weight += item.weight

		if random_value <= accumulated_weight:
			state.item_selected.emit(item)
			return item

	push_error("Failed to select item - this should not happen")
	return state.items[-1]