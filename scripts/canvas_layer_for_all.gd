@tool
extends CanvasLayer

signal signal_btn_next_level()

@export var label_for_level: String = "Level (to be filled)" : \
	set = _set_label_for_level, get = _get_label_for_level

@export var label_description_level: String = "Description (to be filled)" : \
	set = _set_label_description_level, get = _get_label_description_level

# To invert controls:
@export var mobile_left_right_positions: Array[Vector2]
@export var mobile_up_down_positions: Array[Vector2]

@onready var label_level = $LabelLevel
@onready var label_desc = $LabelDesc
@onready var mobile_left_right: Node2D = $mobile_left_right
@onready var mobile_up_down: Node2D = $mobile_up_down

func get_fade_in_out() -> Node2D:
	return find_child("fade_in_out", true, false)
	
func switch_mobile_controls():
	mobile_left_right.position = mobile_left_right_positions[1]
	mobile_left_right.switch_press_zones()
	mobile_up_down.position = mobile_up_down_positions[1]
	
func _ready():
	label_level.text = label_for_level
	label_desc.text = label_description_level
	if not Engine.is_editor_hint():
		mobile_left_right.visible = global.mobile_visible
		mobile_up_down.visible = global.mobile_visible
		# Test: it's working:
		# switch_mobile_controls()

func _get_label_for_level() -> String:
	return label_for_level

func _set_label_for_level(new_value: String) -> void:
	label_for_level = new_value
	if label_level:
		label_level.text = new_value

func _get_label_description_level() -> String:
	return label_description_level

func _set_label_description_level(new_value: String) -> void:
	label_description_level = new_value
	if label_desc:
		label_desc.text = new_value

func _on_touch_screen_button_released():
	if Engine.is_editor_hint():  # in editor = do nothing:
		return
	global.mobile_visible = not global.mobile_visible
	mobile_left_right.visible = global.mobile_visible
	mobile_up_down.visible = global.mobile_visible

func _on_btn_next_level_released():
	emit_signal("signal_btn_next_level")
