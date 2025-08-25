extends GutTest

# Helper function to find a seed that produces a random value in the desired range
func find_seed_for_range(min_val: float, max_val: float) -> int:
	var test_rng = RandomNumberGenerator.new()
	for seed_val in range(10000):
		test_rng.seed = seed_val
		var val = test_rng.randf()
		if val >= min_val and val <= max_val:
			return seed_val
	return 0 # fallback

var wheel_service: WheelService
var wheel_state: WheelState
var provider_root: Node


func before_each():
	# Create a root node that will act as the provider container
	provider_root = Node.new()
	add_child(provider_root)
	
	# Create and provide the WheelState through the Provider system
	wheel_state = WheelState.new()
	provider_root.add_child(wheel_state)
	Provider.provide(provider_root, wheel_state)
	
	# Create the WheelService as a child of the provider root
	# so it can find the provided WheelState through injection
	wheel_service = WheelService.new()
	provider_root.add_child(wheel_service)


func after_each():
	if is_instance_valid(provider_root):
		provider_root.queue_free()


func test_add_item_calls_state_add_item():
	# arrange
	var item = WheelItemResource.new(5.0)
	watch_signals(wheel_state)
	
	# act
	wheel_service.add_item(item)
	
	# assert
	assert_eq(wheel_state.items.size(), 1, "Should add item to state")
	assert_eq(wheel_state.items[0], item, "Should add the correct item")
	assert_signal_emitted(wheel_state, "item_added", "Should emit item_added signal")


func test_clear_items_calls_state_clear_items():
	# arrange
	wheel_service.add_item(WheelItemResource.new(1.0))
	wheel_service.add_item(WheelItemResource.new(2.0))
	watch_signals(wheel_state)
	
	# act
	wheel_service.clear_items()
	
	# assert
	assert_eq(wheel_state.items.size(), 0, "Should clear all items")
	assert_signal_emitted(wheel_state, "items_cleared", "Should emit items_cleared signal")


func test_remove_item_calls_state_remove_item():
	# arrange
	var item1 = WheelItemResource.new(1.0)
	var item2 = WheelItemResource.new(2.0)
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	watch_signals(wheel_state)
	
	# act
	var result = wheel_service.remove_item(item1)
	
	# assert
	assert_true(result, "Should return true when item is removed")
	assert_eq(wheel_state.items.size(), 1, "Should have one item remaining")
	assert_eq(wheel_state.items[0], item2, "Should have correct item remaining")
	assert_signal_emitted(wheel_state, "item_removed", "Should emit item_removed signal")


func test_remove_item_returns_false_for_nonexistent_item():
	# arrange
	var item1 = WheelItemResource.new(1.0)
	var item2 = WheelItemResource.new(2.0)
	wheel_service.add_item(item1)
	
	# act
	var result = wheel_service.remove_item(item2)
	
	# assert
	assert_false(result, "Should return false when item is not found")
	assert_eq(wheel_state.items.size(), 1, "Should still have original item")


func test_get_random_item_distribution_verification():
	# arrange
	var item1 = WheelItemResource.new(1.0) # 10% probability
	var item2 = WheelItemResource.new(9.0) # 90% probability
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	
	var item1_count = 0
	var item2_count = 0
	var total_selections = 1000
	
	# act - run many selections with different seeds
	for i in range(total_selections):
		wheel_service.set_random_seed(i)
		
		var selected_item = wheel_service.get_random_item()
		
		if selected_item == item1:
			item1_count += 1
		elif selected_item == item2:
			item2_count += 1
	
	# assert
	var item1_percentage = float(item1_count) / float(total_selections)
	var item2_percentage = float(item2_count) / float(total_selections)
	
	# Allow some tolerance for the distribution
	assert_almost_eq(item1_percentage, 0.1, 0.02, "Item1 should be selected ~10% of the time")
	assert_almost_eq(item2_percentage, 0.9, 0.02, "Item2 should be selected ~90% of the time")
	assert_eq(item1_count + item2_count, total_selections, "All selections should be accounted for")


func test_get_random_item_edge_case_maximum_random_value():
	# arrange
	var item1 = WheelItemResource.new(5.0)
	var item2 = WheelItemResource.new(5.0)
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	# use a seed that produces a high random value close to 1.0
	var high_seed = find_seed_for_range(0.999, 1.0)
	wheel_service.set_random_seed(high_seed)
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_not_null(result, "Should get an item even with maximum random value")
	assert_true(result == item1 or result == item2, "Should get one of the available items")


func test_get_random_item_returns_null_for_empty_wheel():
	# arrange
	# (wheel is empty by default)
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_null(result, "Should return null for empty wheel")


func test_get_random_item_returns_null_for_zero_weight():
	# arrange
	wheel_service.add_item(WheelItemResource.new(0.0))
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_null(result, "Should return null when total weight is zero")


func test_get_random_item_weighted_selection_boundary():
	# arrange
	var item1 = WheelItemResource.new(3.0) # weight 3, range [0, 3]
	var item2 = WheelItemResource.new(2.0) # weight 2, range (3, 5]
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	# find a seed that produces random value around 0.6 (which gives 3.0 when multiplied by total weight 5)
	var boundary_seed = find_seed_for_range(0.58, 0.62)
	wheel_service.set_random_seed(boundary_seed)
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_eq(result, item1, "Should get first item at boundary")


func test_get_random_item_weighted_selection_first_item():
	# arrange
	var item1 = WheelItemResource.new(3.0) # weight 3
	var item2 = WheelItemResource.new(2.0) # weight 2
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	# find a seed that produces a low random value (around 0.1)
	var low_seed = find_seed_for_range(0.05, 0.15)
	wheel_service.set_random_seed(low_seed)
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_eq(result, item1, "Should get first item with low random value")


func test_get_random_item_weighted_selection_multiple_items():
	# arrange
	var item1 = WheelItemResource.new(1.0) # weight 1, range [0, 1]
	var item2 = WheelItemResource.new(4.0) # weight 4, range (1, 5]
	var item3 = WheelItemResource.new(3.0) # weight 3, range (5, 8]
	var item4 = WheelItemResource.new(2.0) # weight 2, range (8, 10]
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	wheel_service.add_item(item3)
	wheel_service.add_item(item4)
	
	# find a seed that produces random value around 0.7 (which gives 7.0 when multiplied by total weight 10)
	var mid_seed = find_seed_for_range(0.65, 0.75)
	wheel_service.set_random_seed(mid_seed)
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_eq(result, item3, "Should get third item with appropriate random value")


func test_get_random_item_weighted_selection_second_item():
	# arrange
	var item1 = WheelItemResource.new(3.0) # weight 3
	var item2 = WheelItemResource.new(2.0) # weight 2
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)

	# find a seed that produces a high random value (around 0.8)
	var high_seed = find_seed_for_range(0.75, 0.85)
	wheel_service.set_random_seed(high_seed)
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_eq(result, item2, "Should get second item with high random value")


func test_get_random_item_with_single_item():
	# arrange
	var item = WheelItemResource.new(5.0)
	wheel_service.add_item(item)
	wheel_service.set_random_seed(42) # any seed works with single item
	
	# act
	var result = wheel_service.get_random_item()
	
	# assert
	assert_eq(result, item, "Should return the only item")


func test_select_item_sets_selected_item():
	# arrange
	var item = WheelItemResource.new(5.0)
	watch_signals(wheel_state)
	
	# act
	wheel_service.select_item(item)
	
	# assert
	assert_eq(wheel_state.selected_item, item, "Should set the selected item")
	assert_signal_emitted(wheel_state, "item_selected", "Should emit item_selected signal")


func test_set_random_seed_changes_behavior():
	# arrange
	var item1 = WheelItemResource.new(5.0)
	var item2 = WheelItemResource.new(5.0)
	wheel_service.add_item(item1)
	wheel_service.add_item(item2)
	
	# act with first seed
	var low_seed = find_seed_for_range(0.05, 0.15)
	wheel_service.set_random_seed(low_seed)
	var result1 = wheel_service.get_random_item()
	
	# act with second seed
	var high_seed = find_seed_for_range(0.85, 0.95)
	wheel_service.set_random_seed(high_seed)
	var result2 = wheel_service.get_random_item()
	
	# assert
	assert_eq(result1, item1, "Should get first item with low random value")
	assert_eq(result2, item2, "Should get second item with high random value")