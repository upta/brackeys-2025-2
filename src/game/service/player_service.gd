class_name PlayerService
extends Node

@onready var state: PlayerState = Provider.inject(self, PlayerState)

func add_resources(amount: int) -> void:
	state.resources += amount

func remove_resources(amount: int) -> void:
	state.resources = max(0, state.resources - amount)
