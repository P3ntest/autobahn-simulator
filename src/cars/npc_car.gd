class_name NpcCar
extends AnimatableBody3D

@export var speed: float = 22
@export var is_opposite: bool = false

const DESPAWN_DISTANCE: float = 100.0

var instance: CarInstance = null

var pool: CarPool = null

var id: int = 0

var _frame_count: int = 0

var front_cast: RayCast3D

func _ready() -> void:
	add_to_group("NpcCar")

	collision_layer = 1 << 1  # Add to layer 2 (cars)
	collision_layer |= 1 << 2  # Add to layer 3 (killing zone)

	instance.maybe_enable_so_si()

	_setup_front_cast()

func _setup_front_cast() -> void:
	front_cast = RayCast3D.new()
	front_cast.target_position = Vector3(0, 0, -200)
	front_cast.add_exception(self)
	front_cast.collision_mask = 1 << 1 # only collide with cars
	front_cast.position.y = .5 # move slightly upwards
	front_cast.enabled = false
	front_cast.enabled = true
	add_child(front_cast)

func _on_pool_summoned() -> void:
	# Called when the car is summoned from the pool
	# Reset any necessary state here
	_frame_count = 0
	instance.reset()

func virtual_ready() -> void:
	force_update_transform()

func _physics_process(delta: float) -> void:
	_frame_count += 1
	if _frame_count == 1:
		# I'm honestly not sure why this is necessary, but it seems to break the cars spawning position if updated in the first frame
		return  # Skip the first frame to avoid messing with transforms

	var delta_movement = speed * delta * (-1.0 if not is_opposite else 1.0)
	position.z += delta_movement

	instance.turn_wheels(delta_movement)

	if front_cast.is_colliding():
		var collider: Node3D = front_cast.get_collider()
		if collider.is_in_group("Player"):
			if randf() > 0.95:
				instance.toggle_headlights()

	# run this logic only every 10 frames, but offset by the car's id to avoid all cars running this logic on the same frame
	if (_frame_count + id) % 10 == 0:
		var player: Node3D = get_tree().get_first_node_in_group("Player")
		if player == null:
			push_error("No Player found in the scene tree.")
			return
		
		var distance_to_player_z = position.z - player.position.z
		if distance_to_player_z > DESPAWN_DISTANCE:
			pool.return_car(self)

		front_cast.enabled = is_opposite and distance_to_player_z < 0

#todo: headlights
