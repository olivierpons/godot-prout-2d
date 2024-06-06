extends Node2D

#func _ready():
#	if OS.has_feature("mobile") or OS.has_feature("web"):
#		visible = true
#	else:
#		queue_free()

func _on_right_pressed():
	Input.action_press("move_right")

func _on_right_released():
	Input.action_release("move_right")

func _on_left_pressed():
	Input.action_press("move_left")

func _on_left_released():
	Input.action_release("move_left")
