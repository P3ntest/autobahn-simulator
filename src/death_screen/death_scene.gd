extends Control

@export var image: TextureRect

@export var top_speed: Label
@export var distance_traveled: Label
@export var time_played: Label

func set_stats() -> void:
	#wait one frame so the stats are updated before we take the screenshot
	await get_tree().process_frame

	var stats: RunStats = RunStats.current_stats

	top_speed.text = "%d km/h" % (stats.top_speed * 3.6)
	distance_traveled.text = "%d km" % (stats.distance_traveled / 1000.0)
	time_played.text = _display_time_played(stats.time_played)

	image.texture = ImageTexture.create_from_image(stats.picture)

func _display_time_played(seconds: float) -> String:
	var minutes = int(seconds / 60)
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
