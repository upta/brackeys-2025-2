class_name CheckpointState
extends Node

signal checkpoint_reached
signal checkpoint_state_changed(is_at_checkpoint: bool)
signal ticks_changed(ticks_remaining: int)

var max_ticks: int = 2
var ticks_to_checkpoint: int = max_ticks:
	set(value):
		var old_at_checkpoint = ticks_to_checkpoint == 0
		ticks_to_checkpoint = max(0, value)
		var new_at_checkpoint = ticks_to_checkpoint == 0
		
		ticks_changed.emit(ticks_to_checkpoint)
		
		if old_at_checkpoint != new_at_checkpoint:
			checkpoint_state_changed.emit(new_at_checkpoint)
			if new_at_checkpoint:
				checkpoint_reached.emit()


func is_at_checkpoint() -> bool:
	return ticks_to_checkpoint == 0
