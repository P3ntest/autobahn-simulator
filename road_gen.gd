extends Node3D
class_name RoadGen

@export var road_instance: PackedScene
@export var piece_length: float = 20

func _piece_passed() -> void:
	spawn_next_piece()

var starting_length = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in starting_length:
		spawn_next_piece()

var total_pieces = 0

var current_last_index = 0
func spawn_next_piece() -> void:
	var road: RoadPiece = road_instance.instantiate()
	road.transform.origin = Vector3(current_last_index * piece_length, 0, 0)
	road.piece_nr = current_last_index
	add_child(road)
	total_pieces += 1
	current_last_index += 1

	if total_pieces > starting_length + 100:
		print("deleting")
		var children = get_children()
		children[0].queue_free()
		total_pieces -= 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
