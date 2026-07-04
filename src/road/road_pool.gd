class_name RoadPool
extends Node3D

@export var pool_size: int = 20

@export var road_piece_scene: PackedScene
@export var road_size_meters: float = 20

var _current_index: int = 0

var _pieces_order: Array[Node3D] = []

var _frame_counter: int = 0

func _ready() -> void:
	for i in pool_size:
		var road: Node3D = road_piece_scene.instantiate()
		add_child(road)
		_move_to_front(road)

	print("RoadPool ready with ", pool_size, " pieces.")

# Called when the node enters the scene tree for the first time.
func _move_to_front(piece: Node3D) -> void:
	piece.position = Vector3(0, 0, -_current_index * road_size_meters)

	# max because forward is negative z, so we want the most positive to be the last piece
	_pieces_order.append(piece)

	if piece.has_method("_on_summon"):
		piece._on_summon(_current_index)

	_current_index += 1

func _physics_process(_delta: float) -> void:
	_frame_counter += 1
	if _frame_counter % 10 == 0:
		_check_and_recycle()

func _check_and_recycle() -> void:
	var player: Node3D = get_tree().get_first_node_in_group("Player")
	if player == null:
		push_error("No Player found in the scene tree.")
		return

	# keep the length of two roads behind the player
	var allowed_distance: float = road_size_meters * 2

	var last_piece: Node3D = _pieces_order[0]
	var _last_piece_position_z: float = last_piece.position.z

	var distance_to_player_z: float = _last_piece_position_z - player.position.z
	if distance_to_player_z > allowed_distance:
		# recycle the last piece
		_pieces_order.remove_at(0)
		_move_to_front(last_piece)

	