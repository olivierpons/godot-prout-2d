extends Node2D

@export var circle_size: float = 100
@onready var arrow_down = $btn_down/arrow_down
@onready var arrow_up = $btn_up/arrow_up

func _on_btn_up_pressed():
	Input.action_press("jump")
	arrow_up.scale *= 2

func _on_btn_up_released():
	Input.action_release("jump")
	arrow_up.scale /= 2

func _on_btn_down_pressed():
	Input.action_press("move_down")
	arrow_down.scale *= 2

func _on_btn_down_released():
	Input.action_release("move_down")
	arrow_down.scale /= 2
