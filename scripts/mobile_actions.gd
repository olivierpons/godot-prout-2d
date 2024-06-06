extends Node2D

var pressing: bool = false

#func _ready():
#	if OS.has_feature("mobile") or OS.has_feature("web"):
#		visible = true
#	else:
#		queue_free()
		
func _on_button_button_down():
	pressing = true
	Input.action_press("jump")

func _on_button_button_up():
	pressing = false
	Input.action_release("jump")
