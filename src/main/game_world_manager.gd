extends Node

@export var scene: PackedScene

var _current_world: Node

func setup_world() -> void:
	if _current_world:
		_current_world.queue_free()

	_current_world = scene.instantiate()
	add_child(_current_world)