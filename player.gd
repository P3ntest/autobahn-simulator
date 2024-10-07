extends CharacterBody3D

@onready var speedometer: Speedometer = $Speedometer
@onready var wheels: Node3D = $Roadster/Roadster/Wheels


@onready var start_rotation = rotation.y
@onready var cam: Camera3D = $CamPivot/Camera3D


@onready var break_lights: Node3D = $BreakLights

var current_speed = 22.0

var current_turning_speed = 0.0

var dead = false

func _physics_process(delta: float) -> void:
	if (dead):
		return

	# this should drop off with speed like in real life
	var acceleration_power = 1500 / (current_speed + 200)
	var breaking_power = 1500 / (current_speed + 120)

	var default_decay = current_speed * 0.1

	var velocity_delta = (Input.get_action_strength("accelerate") * acceleration_power + Input.get_action_strength("brake") * -breaking_power - default_decay) * delta

	if (Input.is_action_pressed("brake")):
		break_lights.visible = true
	else:
		break_lights.visible = false

	var target_fov = 60 + (velocity_delta / delta)

	current_speed += velocity_delta
	current_speed = max(0, current_speed)

	var forward = -transform.basis.z.normalized()

	var new_velocity = forward * current_speed

	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

	# gravity
	# velocity += get_gravity() * delta

	var turning = Input.get_axis("right", "left") * .2

	current_turning_speed = lerp(current_turning_speed, turning, 4 * delta)

	rotation.y = current_turning_speed + start_rotation
	$CamPivot.rotation.y = -rotation.y + start_rotation

	# wheels
	# for i: Node3D in wheels.get_children():
	# 	# i.rotate_x(current_speed * delta)
	# 	if (i.name.contains("f")):
	# 		i.rotation.y = current_turning_speed

	cam.fov = lerp(cam.fov, target_fov, 4 * delta)

	move_and_slide()

	speedometer._set_speed(current_speed * 3.6)

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
		rb.angular_velocity = Vector3(randf(), randf(), randf()) * 10
		rb.add_child(roadster)

		$PhysicsCollider.queue_free()

		var collider = roadster.get_node("post_mortem_collider")
		roadster.remove_child(collider)
		rb.add_child(collider)

		get_parent().add_child(rb)

		speedometer._set_speed(0)

		dead = true
	else:
		print("hit something else")
		print(body)
		