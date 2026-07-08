extends Node3D

@onready var high: Marker3D = $High
@onready var low: Marker3D = $Low
@onready var camera: Camera3D = $Camera3D

func set_cam_position(_position: float) -> void:
	print("Setting cam position to: ", _position)
	var cam_position = low.position.lerp(high.position, _position)
	camera.position = cam_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_parent().global_position
