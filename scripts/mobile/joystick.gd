extends Node2D

@onready var knob = $knob
@onready var label = $Label
@export var return_duration: float =  0.5
@export var circle_size: float = 100  # Ajustez cette valeur selon vos besoins
var current_direction: Vector2 = Vector2.ZERO

var knob_original_position: Vector2

func _ready():
	knob_original_position = knob.position

func _input(event):
	if event is InputEventScreenDrag:
		update_knob_position(get_global_mouse_position())

func _on_joystick_pressed():
	update_knob_position(get_global_mouse_position())

func _on_joystick_released():
	var tween = create_tween()
	tween.tween_property(
		knob, "position", knob_original_position, return_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reset_input_actions()

func update_knob_position(new_position: Vector2):
	var offset = to_local(new_position) - knob_original_position
	if offset.length() > circle_size:
		offset = offset.normalized() * circle_size
	knob.position = knob_original_position + offset
	var joypad_value = offset / circle_size
	# label.text = "Joypad Value: " + str(joypad_value)

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
	if direction.x == -1:
		Input.action_press("move_left")
		Input.action_release("move_right")
	elif direction.x == 1:
		Input.action_press("move_right")
		Input.action_release("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")
	
	if direction.y == -1:
		Input.action_press("move_up")
		Input.action_release("move_down")
	elif direction.y == 1:
		Input.action_press("move_down")
		Input.action_release("move_up")
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")

func reset_input_actions():
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")
