class_name CheckpointService
extends Node

@onready var state: CheckpointState = Provider.inject(self, CheckpointState)


func reset() -> void:
	state.ticks_to_checkpoint = state.max_ticks


func step() -> void:
	if state.ticks_to_checkpoint > 0:
		state.ticks_to_checkpoint -= 1


func update_max_ticks(ticks: int) -> void:
	state.max_ticks = max(0, ticks)
	state.ticks_to_checkpoint = state.max_ticks