extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		if not body.is_waiting_end_level:
			Engine.time_scale = 0.4
			body.die()
			global.fade_in_out_node.animation_player.play("normal_to_black")
			timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
