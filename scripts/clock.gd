extends Node2D

@export var player: NodePath 
@export var rotation_speed = 1.0

var _player_node: Node

func _ready():
	if not player:  # never call _process() again:
		set_physics_process(false)
	
func _process(delta):
	_player_node = get_node(player)
	if not _player_node:  # never call _process() again:
		set_physics_process(false)
	var player_position = _player_node.global_position
	player_position.y -= 12
	var direction = player_position - global_position
	var target_angle = direction.angle() + PI / 2
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
