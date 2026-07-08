class_name StatsCollector
extends Node

@export var player: CharacterBody3D

var _is_tracking = false

func _ready() -> void:
    EventBus.player_take_control.connect(_on_player_take_control)
    EventBus.player_died.connect(_on_player_died)

func _physics_process(_delta: float) -> void:
    if not _is_tracking:
        return
    RunStats.current_stats.distance_traveled = abs(player.global_position.z)

    RunStats.current_stats.top_speed = max(RunStats.current_stats.top_speed, player.current_speed)

func _on_player_take_control() -> void:
    RunStats.current_stats = RunStats.new()
    RunStats.current_stats.started_playing_at = Time.get_unix_time_from_system()
    _is_tracking = true

func _on_player_died() -> void:
    _is_tracking = false
    var played_duration = Time.get_unix_time_from_system() - RunStats.current_stats.started_playing_at
    RunStats.current_stats.time_played = played_duration

    var picture := get_viewport().get_texture().get_image()
    print("Picture size: %s" % picture.get_size())
    RunStats.current_stats.picture = picture

    print("Run Stats: Top Speed: %s, Distance Traveled: %s, Time Played: %s" % [
        RunStats.current_stats.top_speed,
        RunStats.current_stats.distance_traveled,
        RunStats.current_stats.time_played
    ])