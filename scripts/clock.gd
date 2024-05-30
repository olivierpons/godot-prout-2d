extends Node2D

@export var player : NodePath 

func _process(delta):
	if not player:
		set_physics_process(false)
	
	var player_node = get_node(player)
	if not player_node:
		return
	var player_position = player_node.global_position
	
	var direction = player_position - global_position
	
	# Calcule l'angle en radians
	var angle = direction.angle()
	
	# Applique la rotation à l'objet
	rotation = angle
