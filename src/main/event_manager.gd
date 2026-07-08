extends Node

@onready var chart: StateChart = %StateChart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_take_control.connect(func() -> void:
		chart.send_event("player_take_control")
	)

	EventBus.player_died.connect(func() -> void:
		print("Player died, sending event to chart")
		chart.send_event("player_died")
	)


func _on_dead_state_entered() -> void:
	print("Died entered")
