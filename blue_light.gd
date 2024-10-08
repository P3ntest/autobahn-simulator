extends OmniLight3D

@export var offset = false

const PERIOD = 0.2

var time_passed = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	if time_passed > PERIOD:
		time_passed = 0.0
		offset = !offset
		self.visible = offset
