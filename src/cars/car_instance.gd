class_name CarInstance
extends Node

@export_range(0.0, 1.0, 0.01) var camera_distance: float = 0.0

@export var skin_variants: SkinVariants

@export_group("Headlights")
@export var head_lights: Node3D

@export_group("Wheels")
@export var wheel_radius: float = 0.3
@export var wheels: Array[Node3D] = []

@export_group("SoSi")
@export var has_so_si: bool = false
@export var sound: AudioStreamPlayer3D

@export_group("Skins")
@export var main_mesh: MeshInstance3D
@export var body_surface_slot: int


func _ready() -> void:
	if head_lights:
		head_lights.visible = false

func set_random_skin() -> void:
	if skin_variants and main_mesh:
		var variant = skin_variants.main_materials.pick_random()
		if variant:
			main_mesh.set_surface_override_material(body_surface_slot, variant)

func reset() -> void:
	# Reset the car instance to its initial state
	set_headlights_on(false)
	for wheel in wheels:
		wheel.rotation = Vector3.ZERO

func set_headlights_on(on: bool) -> void:
	if not head_lights:
		return
	head_lights.visible = on

func toggle_headlights() -> void:
	if not head_lights:
		return
	head_lights.visible = not head_lights.visible

func turn_wheels(turn: float) -> void:
	# the turn is in meters, so we need to convert it to radians
	var radians = turn / wheel_radius
	for wheel in wheels:
		wheel.rotate_x(radians)
		wheel.rotation.x = fmod(wheel.rotation.x, TAU)  # Keep the rotation within 0 to 2π

var _components: Array[Node] = []
var _colliders: Array[CollisionShape3D] = []
var _blue_lights: Array[BlueLight] = []

func attach_to_parent(new_parent: CollisionObject3D) -> void:
	if _components.is_empty():
		for child in get_children():
			_components.append(child)
			if child is CollisionShape3D:
				_colliders.append(child)
			if child is BlueLight:
				_blue_lights.append(child)

	for child in _components:
		if child.get_parent():
			child.get_parent().remove_child(child)
		child.owner = null
		new_parent.add_child(child)

func set_body_material(material: Material) -> void:
	main_mesh.set_surface_override_material(body_surface_slot, material)

func maybe_enable_so_si() -> void:
	if has_so_si:
		if randf() < 0.5:
			turn_on_so_si()
		else:
			turn_off_so_si()

func check_has_so_si() -> bool:
	return has_so_si

func toggle_so_si() -> void:
	if not has_so_si:
		return
	if _so_si_enabled:
		turn_off_so_si()
	else:
		turn_on_so_si()

var _so_si_enabled: bool = false
func turn_on_so_si() -> void:
	if not has_so_si:
		return
	_so_si_enabled = true
	for blue_light in _blue_lights:
		blue_light.enabled = true

	sound.stop()
	sound.play()

func turn_off_so_si() -> void:
	if not has_so_si:
		return
	_so_si_enabled = false
	for blue_light in _blue_lights:
		blue_light.enabled = false

	sound.stop()
	

func set_player() -> void:
	if sound:
		sound.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
