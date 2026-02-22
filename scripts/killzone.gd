class_name Killzone
extends Area2D

const SLOW_MOTION_SCALE: float = 0.4
const NORMAL_TIME_SCALE: float = 1.0

@onready var _timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.is_waiting_end_level:
		return
	Engine.time_scale = SLOW_MOTION_SCALE
	body.die()
	_timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = NORMAL_TIME_SCALE
	get_tree().reload_current_scene()
