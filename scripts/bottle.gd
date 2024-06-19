extends Node2D

func _ready():
	pass

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.change_max_horizontal_speed.emit(1000.0)
