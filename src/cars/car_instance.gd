class_name CarInstance
extends Node

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

func turn_on_so_si_if_has_sound() -> void:
	if has_so_si and sound != null:
		sound.play()

func turn_wheels(turn: float) -> void:
	# the turn is in meters, so we need to convert it to radians
	var radians = turn / wheel_radius
	for wheel in wheels:
		wheel.rotate_x(radians)
		wheel.rotation.x = fmod(wheel.rotation.x, TAU)  # Keep the rotation within 0 to 2π

func attach_to_parent(new_parent: CollisionObject3D) -> void:
	for child in get_children():
		remove_child(child)
		child.owner = null
		new_parent.add_child(child)

func set_body_material(material: Material) -> void:
	main_mesh.set_surface_override_material(body_surface_slot, material)
