extends Node2D

@export var circle_size: float = 100
var pressing: bool = false
var index_pressed: int = -1
@onready var knob = $Knob

#func _ready():
#	if OS.has_feature("mobile") or OS.has_feature("web"):
#		visible = true
#	else:
#		queue_free()
		

func _input(event):
	if event is InputEventScreenTouch:
		var local_mouse_pos: Vector2 = to_local(get_global_mouse_position())
		if event.pressed and index_pressed < 0:
			if (local_mouse_pos - knob.position).length() <= circle_size:
				index_pressed = event.get_index()
				Input.action_press("jump")
		elif not event.pressed and index_pressed >= 0:
			index_pressed = -1
			Input.action_release("jump")


func _on_pressed():
	print("_on_pressed")


func _on_released():
	print("_on_released")
