extends Node2D

@onready var arrow_left = $btn_left/arrow_left
@onready var arrow_right = $btn_right/arrow_right

func _on_btn_left_pressed():
	Input.action_press("move_left")
	arrow_left.scale *= 2

func _on_btn_left_released():
	Input.action_release("move_left")
	arrow_left.scale /= 2

func _on_btn_right_pressed():
	Input.action_press("move_right")
	arrow_right.scale *= 2

func _on_btn_right_released():
	Input.action_release("move_right")
	arrow_right.scale /= 2
