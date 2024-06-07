extends Node2D

@onready var knob = $knob
@onready var label = $Label
@export var return_duration: float =  0.5
@export var circle_size: float = 100
var current_direction: Vector2 = Vector2.ZERO
var index_dragging: int = -1

var knob_local_position: Vector2

func _ready():
	knob_local_position = knob.position

func _input(event):
	if event is InputEventScreenDrag and index_dragging >= 0:
		var local_mouse_pos: Vector2 = to_local(get_global_mouse_position())
		if event.get_index() == index_dragging:
			update_knob_position(local_mouse_pos)
	elif event is InputEventScreenTouch:
		var local_mouse_pos: Vector2 = to_local(get_global_mouse_position())
		if event.pressed:
			if (local_mouse_pos - knob.position).length() <= circle_size:
				index_dragging = event.get_index()
				update_knob_position(local_mouse_pos)
		else:
			index_dragging = -1
			var tween = create_tween()
			tween.tween_property(
				knob, "position", knob_local_position, return_duration
			).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			# reset_input_actions:
			Input.action_release("move_left")
			Input.action_release("move_right")
			Input.action_release("move_up")
			Input.action_release("move_down")

func update_knob_position(new_position: Vector2):
	var offset = new_position - knob_local_position
	if offset.length() > circle_size:
		offset = offset.normalized() * circle_size
	knob.position = knob_local_position + offset
	var joypad_value = offset / circle_size
	label.text = "Joypad Value: " + str(joypad_value)

	var new_direction = Vector2.ZERO
	if joypad_value.x < -0.1:
		new_direction.x = -1
	elif joypad_value.x > 0.1:
		new_direction.x = 1
	if joypad_value.y < -0.1:
		new_direction.y = -1
	elif joypad_value.y > 0.1:
		new_direction.y = 1
	
	if new_direction != current_direction:
		label.text = str(new_direction)
		update_input_actions(new_direction)
		current_direction = new_direction

func update_input_actions(direction: Vector2):
	label.text = ""
	if direction.x == -1:
		label.text += "<"
		Input.action_press("move_left")
		Input.action_release("move_right")
	elif direction.x == 1:
		label.text += ">"
		Input.action_press("move_right")
		Input.action_release("move_left")
	else:
		label.text += "-"
		Input.action_release("move_left")
		Input.action_release("move_right")
	
	if direction.y == -1:
		label.text += "n"
		Input.action_press("move_up")
		Input.action_release("move_down")
	elif direction.y == 1:
		label.text += "v"
		Input.action_press("move_down")
		Input.action_release("move_up")
	else:
		label.text += "-"
		Input.action_release("move_up")
		Input.action_release("move_down")

