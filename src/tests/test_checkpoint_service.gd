extends GutTest

var checkpoint_service: CheckpointService
var checkpoint_state: CheckpointState
var provider_root: Node


func after_each():
	if is_instance_valid(provider_root):
		provider_root.queue_free()


func before_each():
	provider_root = Node.new()
	add_child(provider_root)
	
	checkpoint_state = CheckpointState.new()
	provider_root.add_child(checkpoint_state)
	Provider.provide(provider_root, checkpoint_state)
	
	checkpoint_service = CheckpointService.new()
	provider_root.add_child(checkpoint_service)


func test_initial_state_is_not_at_checkpoint():
	# arrange
	# (checkpoint_state is initialized with 1 tick by default)
	# act
	var result = checkpoint_state.is_at_checkpoint()
	
	# assert
	assert_false(result, "Should not be at checkpoint initially with 1 tick")


func test_multiple_steps_reach_checkpoint():
	# arrange
	checkpoint_service.update_max_ticks(3)
	watch_signals(checkpoint_state)
	
	# act
	checkpoint_service.step()
	checkpoint_service.step()
	checkpoint_service.step()
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, 0, "Should reach 0 ticks after 3 steps")
	assert_true(checkpoint_state.is_at_checkpoint(), "Should be at checkpoint")
	assert_signal_emitted(checkpoint_state, "checkpoint_reached", "Should emit checkpoint_reached signal")
	assert_signal_emit_count(checkpoint_state, "checkpoint_reached", 1, "Should emit signal only once")


func test_set_negative_ticks_clamps_to_zero():
	# arrange
	var negative_ticks = -3
	
	# act
	checkpoint_service.update_max_ticks(negative_ticks)
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, 0, "Should clamp negative ticks to 0")
	assert_true(checkpoint_state.is_at_checkpoint(), "Should be at checkpoint with 0 ticks")


func test_set_ticks_to_checkpoint():
	# arrange
	var ticks = 5
	
	# act
	checkpoint_service.update_max_ticks(ticks)
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, ticks, "Should set ticks to checkpoint")
	assert_false(checkpoint_state.is_at_checkpoint(), "Should not be at checkpoint with ticks > 0")


func test_step_does_not_go_below_zero():
	# arrange
	checkpoint_service.update_max_ticks(0)
	watch_signals(checkpoint_state)
	
	# act
	checkpoint_service.step()
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, 0, "Should stay at 0 ticks")
	assert_true(checkpoint_state.is_at_checkpoint(), "Should still be at checkpoint")
	assert_signal_not_emitted(checkpoint_state, "checkpoint_reached", "Should not emit signal when already at checkpoint")


func test_step_emits_signal_when_reaching_checkpoint():
	# arrange
	checkpoint_service.update_max_ticks(1)
	watch_signals(checkpoint_state)
	
	# act
	checkpoint_service.step()
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, 0, "Should reach 0 ticks")
	assert_true(checkpoint_state.is_at_checkpoint(), "Should be at checkpoint")
	assert_signal_emitted(checkpoint_state, "checkpoint_reached", "Should emit checkpoint_reached signal")


func test_step_reduces_ticks():
	# arrange
	checkpoint_service.update_max_ticks(3)
	
	# act
	checkpoint_service.step()
	
	# assert
	assert_eq(checkpoint_state.ticks_to_checkpoint, 2, "Should reduce ticks by 1")
	assert_false(checkpoint_state.is_at_checkpoint(), "Should not be at checkpoint yet")