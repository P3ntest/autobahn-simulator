extends Node3D
class_name RoadPiece


@export var piece_nr = 0

func _on_sensor_passed(node: Node3D):
	if node.get_groups().has("Player"):
		if get_parent() is RoadGen:
			get_parent()._piece_passed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cars = $Cars
	for i in cars.get_children():
		var old_global_transform = i.global_transform
		$Cars.remove_child(i)
		get_tree().get_first_node_in_group("CarHolder").add_child(i)
		i.global_transform = old_global_transform
