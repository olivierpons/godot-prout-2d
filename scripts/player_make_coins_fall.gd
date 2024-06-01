extends Area2D

func _on_body_entered(_body):
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.set_physics_process(true)
