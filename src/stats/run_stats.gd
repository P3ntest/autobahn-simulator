class_name RunStats
extends Resource

static var current_stats: RunStats = RunStats.new()

@export var top_speed: float = 0.0
@export var distance_traveled: float = 0.0
@export var time_played: float = 0.0

var picture: Image

var started_playing_at: float = 0