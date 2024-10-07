extends Node3D
class_name RoadPiece


@export var piece_nr = 0

func _on_sensor_passed(node: Node3D):
	if node.get_groups().has("Player"):
		if get_parent() is RoadGen:
			get_parent()._piece_passed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
