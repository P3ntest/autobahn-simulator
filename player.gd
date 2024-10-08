extends CharacterBody3D

@onready var speedometer: Speedometer = $Speedometer
@onready var wheels: Node3D = $Roadster/Roadster/Wheels


@onready var start_rotation = rotation.y
@onready var cam: Camera3D = $CamPivot/Camera3D

@export var break_decal: PackedScene

@onready var engine_sound: AudioStreamPlayer = $EngineSound
@onready var break_sound: AudioStreamPlayer = $BreakSound
@onready var crash_sound: AudioStreamPlayer = $CrashSound
@onready var swoosh_sound: AudioStreamPlayer = $SwooshSound

@onready var break_lights: Node3D = $BreakLights

var started = false

# Stats
var highest_speed = 0
var score = 0


func _ready():
	engine_sound.play()

var current_speed = 30.0

var current_turning_speed = 0.0

var dead = false

var target_engine_pitch = 1.0
var target_engine_volume = 1.0

func start():
	started = true

func _physics_process(delta: float) -> void:
	if (dead):
		if (Input.is_action_just_pressed("restart")):
			get_tree().reload_current_scene()
		cam.fov = lerp(cam.fov, 40.0, 12 * delta)
		return

	# this should drop off with speed like in real life
	var acceleration_power = 1300 / (current_speed + 300)
	var breaking_power = 10

	var default_decay = current_speed * 0.03 if started else 0

	var velocity_delta = (Input.get_action_strength("accelerate") * acceleration_power + Input.get_action_strength("brake") * -breaking_power - default_decay) * delta

	if not started and velocity_delta > 0:
		start()

	target_engine_pitch = .4 + max(velocity_delta, 0) * 1.2 + current_speed * 0.03
	target_engine_volume = 1 + current_speed * 0.01

	if (Input.is_action_pressed("brake")):
		break_lights.visible = true
		break_sound.volume_db = linear_to_db(current_speed * 0.03)
	else:
		break_lights.visible = false
		break_sound.stop()

	if (Input.is_action_just_pressed("brake")):
		break_sound.play()

	var target_fov = 65 + ((velocity_delta * 2) / delta) + current_speed * 0.5

	current_speed += velocity_delta
	current_speed = max(0, current_speed)

	score += pow(current_speed, 1.7) * delta * 0.002
	highest_speed = max(highest_speed, current_speed)

	var forward = -transform.basis.z.normalized()

	var new_velocity = forward * current_speed

	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

	if velocity_delta < 10 * delta and Input.is_action_pressed("brake"):
		for spawner: Node3D in $DecalSpawners.get_children():
			var decal = break_decal.instantiate()
			decal.transform.origin = spawner.global_position
			get_parent().add_child(decal)

	# gravity
	# velocity += get_gravity() * delta

	var turning = Input.get_axis("right", "left") * .25

	current_turning_speed = lerp(current_turning_speed, turning, (current_speed / 10) * delta)

	if Input.is_action_pressed("brake"):
		var rand_range = -velocity_delta * current_speed * delta * 0.1
		current_turning_speed += randf_range(-rand_range, rand_range)
		current_turning_speed *= 1 + delta * abs(velocity_delta) * 0.2 * current_speed


	rotation.y = current_turning_speed + start_rotation
	$CamPivot.rotation.y = -rotation.y + start_rotation

	# wheels
	# for i: Node3D in wheels.get_children():
	# 	# i.rotate_x(current_speed * delta)
	# 	if (i.name.contains("f")):
	# 		i.rotation.y = current_turning_speed

	cam.fov = lerp(cam.fov, target_fov, 1.5 * delta)

	engine_sound.pitch_scale = lerp(engine_sound.pitch_scale, target_engine_pitch, 4 * delta)
	engine_sound.volume_db = lerp(engine_sound.volume_db, target_engine_volume, 4 * delta)

	move_and_slide()

	speedometer._set_speed(current_speed * 3.6)
	$Score.text = "Score: " + str(round(score)) + "\nMax: " + str(ceil(highest_speed * 3.6)) + " km/h"

func _on_close_detector_body_exited(body: NpcCar):
	if dead:
		return

	var other_speed = -body.speed if body.is_opposite else body.speed
	var speed_diff = current_speed - other_speed
	if speed_diff > 45:
		swoosh_sound.play()
		speed_diff -= 45
		score += pow(speed_diff, 1.7) * 0.1


func _on_collision_detector_body_entered(body: Node3D):
	if (dead):
		return

	if (body.get_groups().has("NpcCar")):
		print("hit car we ded")

		$BreakLights.visible = false

		# we want to replace this with a rigid body to fly away
		var roadster: Node3D = $Roadster
		remove_child(roadster)

		roadster.scale.z = 1 - min(current_speed / 800, 0.5)
		
		var rb = RigidBody3D.new()
		rb.transform = transform
		rb.linear_velocity = velocity * 2 + Vector3(0, 2 + current_speed / 20, 0)
		rb.angular_velocity = Vector3(randf(), randf(), randf()) * current_speed / 20
		rb.add_child(roadster)

		$PhysicsCollider.queue_free()

		var collider = roadster.get_node("post_mortem_collider")
		roadster.remove_child(collider)
		rb.add_child(collider)

		get_parent().add_child(rb)

		engine_sound.stop()
		break_sound.stop()

		crash_sound.play()

		speedometer._set_speed(0)

		$DeathScreen.visible = true

		dead = true
	else:
		print("hit something else")
		print(body)
		
