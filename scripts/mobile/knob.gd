extends Sprite2D

@onready var parent = $".."

@export var max_length = 24
var pressing: bool = false
var just_released: bool = false
var dead_zone: int = 4
var is_moving: bool = false

func _ready():
	dead_zone = parent.dead_zone

func _process(delta):
	if pressing:
		var m_p: Vector2 = get_global_mouse_position()
		if m_p.distance_to(parent.global_position) <= max_length:
			global_position = m_p
		else:
			var angle = parent.global_position.angle_to_point(m_p)
			global_position.x = parent.global_position.x + cos(angle)*max_length
			global_position.y = parent.global_position.y + sin(angle)*max_length
		calculate_vector()
		var x: float = parent.pos_vector.x
		var y: float = parent.pos_vector.y
		if (y > -.33) and (y < .33):
			if x < -.5:
				Input.action_press("move_left")
				is_moving = true
			elif x > .5:
				Input.action_press("move_right")
				is_moving = true
			else:
				Input.action_release("move_left")
				Input.action_release("move_right")
				is_moving = false
	else:
		if just_released:
			just_released = false
			Input.action_release("move_left")
			Input.action_release("move_right")
			is_moving = false

		global_position = lerp(global_position, parent.global_position, delta*50)
		parent.pos_vector = Vector2(0,0)
		
func calculate_vector():
	var diff_x: float = global_position.x - parent.global_position.x
	var diff_y: float = global_position.y - parent.global_position.y
	if abs(diff_x) >= dead_zone:
		parent.pos_vector.x = diff_x / max_length
	if abs(diff_y) >= dead_zone:
		parent.pos_vector.y = diff_y / max_length
		
func _on_button_button_down():
	pressing = true

func _on_button_button_up():
	pressing = false
	just_released = true
