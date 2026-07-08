extends CharacterBody3D


signal speed_changed(new_speed_ms: float)
signal camera_position_changed(new_position: float)


@onready var start_rotation = rotation.y
@onready var cam: Camera3D = $CamPivot/Camera3D

@onready var engine_sound: AudioStreamPlayer = $EngineSound
@onready var break_sound: AudioStreamPlayer = $BreakSound
@onready var crash_sound: AudioStreamPlayer = $CrashSound
@onready var swoosh_sound: AudioStreamPlayer = $SwooshSound

var started = false

var _car_instance: CarInstance

@export var debug_set_car: PackedScene

@onready var collision_detector: Area3D = $CollisionDetector

func set_car(scene: PackedScene) -> void:
	_car_instance = scene.instantiate()
	add_child(_car_instance)
	_car_instance.attach_to_parent(self)
	_car_instance.set_player()

	camera_position_changed.emit(_car_instance.camera_distance)

	for collider in collision_detector.get_children():
		collider.queue_free()
	for collider in _car_instance._colliders:
		var duplicate_collider = collider.duplicate() as CollisionShape3D
		collision_detector.add_child(duplicate_collider)

func _ready():
	collision_layer |= 1 << 1  # Add to layer 2 (cars)

	add_to_group("Player")

	engine_sound.play()

	if debug_set_car:
		set_car(debug_set_car)

var current_speed = 30.0

var current_turning_speed = 0.0

var dead = false

var target_engine_pitch = 1.0
var target_engine_volume = 1.0

func start():
	if started:
		return
	started = true
	EventBus.player_take_control.emit()

func _car_effects_process() -> void:
	if Input.is_action_just_pressed("sosi"):
		if _car_instance.check_has_so_si():
			_car_instance.toggle_so_si()

func _physics_process(delta: float) -> void:
	if (dead):
		if (Input.is_action_just_pressed("restart")):
			get_tree().reload_current_scene()
		cam.fov = lerp(cam.fov, 40.0, 12 * delta)
		return

	_car_effects_process()

	# this should drop off with speed like in real life
	var acceleration_power = 1300 / (current_speed + 300)
	var breaking_power = 10

	var default_decay = current_speed * 0.03 if started else 0.0

	var velocity_delta = (Input.get_action_strength("accelerate") * acceleration_power + Input.get_action_strength("brake") * -breaking_power - default_decay) * delta

	if velocity_delta > 0:
		start()

	target_engine_pitch = .4 + max(velocity_delta, 0) * 1.2 + current_speed * 0.03
	target_engine_volume = 1 + current_speed * 0.01

	if (Input.is_action_pressed("brake")):
		#break lights
		break_sound.volume_db = linear_to_db(current_speed * 0.03)
	else:
		#break lights
		break_sound.stop()

	if (Input.is_action_just_pressed("brake")):
		break_sound.play()

	var target_fov = 35 + ((velocity_delta * 2) / delta) + current_speed * 0.5

	current_speed += velocity_delta
	current_speed = max(0, current_speed)

	var forward = -transform.basis.z.normalized()

	var new_velocity = forward * current_speed

	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

	# gravity
	# velocity += get_gravity() * delta

	var turning = Input.get_axis("right", "left") * .25

	if abs(turning) > 0.01:
		start()

	current_turning_speed = lerp(current_turning_speed, turning, (current_speed / 10) * delta)

	if Input.is_action_pressed("brake"):
		var rand_range = -velocity_delta * current_speed * delta * 0.1
		current_turning_speed += randf_range(-rand_range, rand_range)
		current_turning_speed *= 1 + delta * abs(velocity_delta) * 0.2 * current_speed


	rotation.y = current_turning_speed + start_rotation

	cam.fov = lerp(cam.fov, target_fov, 1.5 * delta)

	engine_sound.pitch_scale = lerp(engine_sound.pitch_scale, target_engine_pitch, 4 * delta)
	engine_sound.volume_db = lerp(engine_sound.volume_db, target_engine_volume, 4 * delta)

	move_and_slide()

	speed_changed.emit(current_speed)

func _on_collision_detector_body_entered(_body: Node3D):
	if (dead):
		return

	_death()

func _death() -> void:
	EventBus.player_died.emit()
	# break lights

	_car_instance.turn_off_so_si()
	
	var rb = RigidBody3D.new()
	rb.collision_mask |= 1 << 1
	rb.transform = transform
	rb.linear_velocity = velocity * 2 + Vector3(0, 2 + current_speed / 20, 0)
	rb.angular_velocity = Vector3(randf(), randf(), randf()) * current_speed / 20

	_car_instance.attach_to_parent(rb)

	get_parent().add_child(rb)

	engine_sound.stop()
	break_sound.stop()

	crash_sound.play()

	speed_changed.emit(0)

	dead = true
