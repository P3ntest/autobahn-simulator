extends TextureRect
class_name Speedometer

@onready var needle: TextureRect = $Needle
@onready var label: Label = $kmh_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var target_rotation = 0
var current_speed = 0
func _set_speed(speed: float) -> void:
	# speedometer goes from 0 to 280 km/h in 3/4 rotation
	target_rotation = (speed / 280) * 270
	current_speed = speed

@onready var base_rotation = needle.rotation_degrees

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	needle.rotation_degrees = lerp(needle.rotation_degrees, target_rotation + base_rotation, 4 * delta)
	label.text = str(round(current_speed))
