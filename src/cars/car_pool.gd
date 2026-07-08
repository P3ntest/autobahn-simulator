class_name CarPool
extends Node3D

@export var car_instances: Array[CarPoolVariant] = []
var _total_chance: float = 0.0

var _highest_id: int = 0

@export var min_pool_size: int = 5

var stored_objects: Array[Node3D] = []

func _ready() -> void:
    _calculate_total_chance()

    for i in range(min_pool_size):
        var car = _generate_car()
        _store_object(car)

func request_car() -> Node3D:
    if stored_objects.size() > 0:
        var car = stored_objects.pick_random()
        _unstore_object(car)
        return car
    else:
        var car = _generate_car()
        _unstore_object(car)
        return car

func return_car(car: Node3D) -> void:
    _store_object(car)

func _calculate_total_chance() -> void:
    _total_chance = 0.0
    for variant in car_instances:
        _total_chance += variant.spawn_chance

func _generate_car() -> Node3D:
    var car: NpcCar = NpcCar.new()

    var variant_instance: CarInstance = _pick_random_variant().prefab.instantiate() as CarInstance

    car.add_child(variant_instance)

    variant_instance.set_random_skin()

    variant_instance.attach_to_parent(car)

    car.instance = variant_instance

    car.pool = self

    car.id = _highest_id
    _highest_id += 1

    car.position = Vector3(0, -500, 0)  # Move the car far below the scene to avoid it being visible

    add_child(car)

    return car

func _pick_random_variant() -> CarPoolVariant:
    if _total_chance <= 0.0:
        _calculate_total_chance()

    var random_value = randf() * _total_chance
    var cumulative_chance = 0.0

    for variant in car_instances:
        cumulative_chance += variant.spawn_chance
        if random_value <= cumulative_chance:
            return variant
    return null  # Should not reach here if total chance is calculated correctly

func _store_object(obj: Node3D) -> void:
    obj.process_mode = Node.PROCESS_MODE_DISABLED
    obj.position = Vector3(0, -500, 0)  # Move the car far below the scene to avoid it being visible
    obj.visible = false

    if obj.has_method("_on_pool_stored"):
        obj._on_pool_stored()

    stored_objects.append(obj)

func _unstore_object(obj: Node3D) -> void:
    # obj.process_mode = Node.PROCESS_MODE_INHERIT
    obj.visible = true

    if obj.has_method("_on_pool_summoned"):
        obj._on_pool_summoned()

    stored_objects.erase(obj)
