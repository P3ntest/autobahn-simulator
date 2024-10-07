extends CharacterBody3D

@export var car_chance: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("NpcCar")
	if randf() > car_chance:
		queue_free()
		return

	var variants: Node3D = $Variants
	var selected_variant: Node3D = variants.get_child(randi() % variants.get_child_count())
	selected_variant.visible = true
	var collission: CollisionShape3D = selected_variant.get_node("CollisionShape3D")
	selected_variant.remove_child(collission)
	add_child(collission)
	# delete the other roads
	for i in variants.get_children():
		if i != selected_variant:
			i.queue_free()

	translate(Vector3(0, 0, randf_range(-0.5, .5)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var speed = 22
func _process(delta: float) -> void:
	var forward = transform.basis.z.normalized()

	var new_velocity = forward * speed
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

	move_and_slide()
