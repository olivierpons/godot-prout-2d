extends TouchScreenButton

@onready var knob = $"knob"
@onready var label = $"Label"
@export var return_duration: float =  0.5
@export var circle_size: float = 100
@export var dead_zone: float = 30.0

var current_direction: Vector2 = Vector2.ZERO
var is_dragging: bool = false

var knob_local_position: Vector2

func _ready():
	knob_local_position = knob.position

func is_point_in_circle(point: Vector2) -> bool:
	var distance = point.distance_to(Vector2.ZERO)
	return distance <= circle_size

func _input(event):
	if event is InputEventScreenDrag and is_dragging and is_point_in_circle(to_local(event.position)):
		update_knob_position(to_local(event.position))

func update_knob_position(new_position: Vector2):
	new_position.limit_length(circle_size)
	knob.position = new_position.limit_length(circle_size)
	var joypad_value = knob.position
	var new_direction = Vector2.ZERO
	if joypad_value.x < -dead_zone:
		new_direction.x = -1
	elif joypad_value.x > dead_zone:
		new_direction.x = 1
	if joypad_value.y < -dead_zone:
		new_direction.y = -1
	elif joypad_value.y > dead_zone:
		new_direction.y = 1
	
	if new_direction != current_direction:
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

func _on_pressed():
	is_dragging = true

func _on_released():
	label.text += "-" + str(is_dragging)
	is_dragging = false
	var tween = create_tween()
	tween.tween_property(
		knob, "position", knob_local_position, return_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# reset_input_actions:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")
