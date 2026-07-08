class_name BlueLight
extends OmniLight3D

@export var enabled = false:
	set(value):
		enabled = value
		time_passed = 0.0
		if not value:
			self.visible = false

@export var offset = false

const PERIOD = 0.15

var time_passed = 0.0

func _ready() -> void:
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enabled:
		return
	time_passed += delta
	if time_passed > PERIOD:
		time_passed = 0.0
		offset = !offset
		self.visible = offset
