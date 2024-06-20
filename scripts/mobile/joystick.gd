extends Node2D

@onready var arrow_left = $btn_left/arrow_left
@onready var arrow_right = $btn_right/arrow_right
@onready var btn_left: TouchScreenButton = $btn_left
@onready var btn_right: TouchScreenButton = $btn_right

func switch_press_zones():
	var old_left: Vector2 = btn_left.shape.size
	btn_left.shape.size = btn_right.shape.size
	btn_right.shape.size = old_left

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
