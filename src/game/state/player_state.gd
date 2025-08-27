class_name PlayerState
extends Node

signal resources_changed(old_amount: int, new_amount: int)

var resources: int = 0:
	get:
		return resources
	set(value):
		if value != resources:
			var old = resources
			resources = value
			resources_changed.emit(old, resources)
