extends Node2D

@export var circle_size: float = 100

func _on_pressed():
	Input.action_press("jump")

func _on_released():
	Input.action_release("jump")

func _on_btn_up_pressed():
	Input.action_press("jump")

func _on_btn_up_released():
	Input.action_release("jump")
