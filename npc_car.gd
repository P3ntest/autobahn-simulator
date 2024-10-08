extends AnimatableBody3D
class_name NpcCar

@export var car_chance: float = 0.25

@export var is_opposite: bool = false

func get_variant_spawn_chance(variant: Node3D) -> float:
	if (variant.has_node("SpawnChance")):
		return variant.get_node("SpawnChance").spawn_chance
	else:
		return 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("NpcCar")
	if randf() > car_chance:
		queue_free()
		return

	var variants: Node3D = $Variants

	var total_weight: float = 0
	for i in variants.get_children():
		total_weight += get_variant_spawn_chance(i)
	
	var rand: float = randf_range(0, total_weight)
	var selected_variant: Node3D = null
	for i in variants.get_children():
		rand -= get_variant_spawn_chance(i)
		if rand <= 0:
			selected_variant = i
			break

	selected_variant.visible = true
	var collission: CollisionShape3D = selected_variant.get_node("CollisionShape3D")
	selected_variant.remove_child(collission)
	add_child(collission)
	# delete the other roads
	for i in variants.get_children():
		if i != selected_variant:
			i.queue_free()

	if selected_variant.has_node(("HeadlightPosition")):
		var marker: Marker3D = selected_variant.get_node("HeadlightPosition")
		$Headlights.transform.origin = marker.transform.origin

	
	for child in selected_variant.get_children():
		if child is AudioStreamPlayer3D:
			child.play()
	
	const OFFSET = 1
	translate(Vector3(randf_range(-OFFSET, OFFSET), 0, 0))

@onready var front_cast: RayCast3D = $FrontCast

# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var speed = 22
func _process(delta: float) -> void:
	translate(Vector3(0, 0,  speed * delta))

	if is_opposite:
		if front_cast.is_colliding() and front_cast.get_collider().get_groups().has("Player"):
			if (randf() > 0.995):
				$Headlights.visible = !$Headlights.visible
		else:
			$Headlights.visible = false
	
	var player = get_tree().get_first_node_in_group("Player")
	var player_delta = player.global_transform.origin.x - global_transform.origin.x
	if player_delta > 40:
		queue_free()	

