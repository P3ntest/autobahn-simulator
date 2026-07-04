class_name RoadPiece
extends Node3D

@export var npc_car_spawners: Array[NpcCarSpawner] = []

func _on_summon(piece_index: int) -> void:
	if piece_index > 1:
		for spawner in npc_car_spawners:
			spawner.attempt_spawn()