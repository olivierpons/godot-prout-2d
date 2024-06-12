@tool
extends CanvasLayer

@export var label_for_level: String = "Level (to be filled)" : \
	set = _set_label_for_level, get = _get_label_for_level

@export var label_description_level: String = "Description (to be filled)" : \
	set = _set_label_description_level, get = _get_label_description_level

@onready var label_level = $LabelLevel
@onready var label_desc = $LabelDesc
@onready var mobile_joystick = $"mobile-joystick"
@onready var mobile_up_down: Node2D = $mobile_up_down

func _ready():
	label_level.text = label_for_level
	label_desc.text = label_description_level
	if not Engine.is_editor_hint():
		mobile_joystick.visible = global.mobile_visible
		mobile_up_down.visible = global.mobile_visible

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
	mobile_joystick.visible = global.mobile_visible
	mobile_up_down.visible = global.mobile_visible
