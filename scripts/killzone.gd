extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# body is the player!
	if body.is_in_group("player"):
		Engine.time_scale = 0.4
		body.is_dying = true
		body.get_node("AnimationPlayer").play("die")
		body.get_node("CollisionShape2D").queue_free()
		body.play_random_hurt()
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
