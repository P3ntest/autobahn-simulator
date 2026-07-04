class_name NpcCarSpawner
extends Marker3D

@export var speed: float = 22
@export var is_opposite: bool = false

@export var spawn_chance: float = 0.25
@export var offset: float = 1.0

# Called when the node enters the scene tree for the first time.
func attempt_spawn() -> void:
	if randf() > spawn_chance:
		return

	var pool: CarPool = get_tree().get_first_node_in_group("CarPool")
	if pool == null:
		push_error("No CarPool found in the scene tree.")


	var spawn_transform: Transform3D = global_transform
	spawn_transform.origin.x += randf_range(-offset, offset)

	var car: NpcCar = pool.request_car()

	car.transform = spawn_transform

	print("moving car to ", spawn_transform.origin)

	car.speed = speed
	car.is_opposite = is_opposite

	car.virtual_ready()

	car.process_mode = Node.PROCESS_MODE_INHERIT

	