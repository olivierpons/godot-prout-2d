extends Node

"""Tracks the last input device and provides readable action labels.

Autoload: input_helper
"""

signal device_changed(is_joypad: bool)

var is_joypad: bool = false


func _input(event: InputEvent) -> void:
	var was_joypad: bool = is_joypad
	if (
		event is InputEventJoypadButton
		or event is InputEventJoypadMotion
	):
		is_joypad = true
	elif (
		event is InputEventKey
		or event is InputEventMouse
		or event is InputEventMouseButton
	):
		is_joypad = false
	if is_joypad != was_joypad:
		device_changed.emit(is_joypad)


func get_action_label(action: String) -> String:
	"""Return a human-readable label for the given action.

	Shows the key name for keyboard, or the button name for joypad.

	Args:
		action: The Input Map action name.

	Returns:
		A display string like "E" or "Xbox A".
	"""
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for event: InputEvent in events:
		if is_joypad and event is InputEventJoypadButton:
			return _joypad_button_name(event.button_index)
		if not is_joypad and event is InputEventKey:
			var code: int = event.keycode
			if code == KEY_NONE:
				code = DisplayServer.keyboard_get_keycode_from_physical(
					event.physical_keycode
				)
			return OS.get_keycode_string(code)
	# Fallback: return first event of any type:
	if events.size() > 0:
		return events[0].as_text().split(" (")[0]
	return action


func _joypad_button_name(button: JoyButton) -> String:
	"""Return a readable name for a joypad button.

	Args:
		button: The JoyButton index.

	Returns:
		A display string like "A", "B", "X", "Y", etc.
	"""
	match button:
		JOY_BUTTON_A:
			return "A"
		JOY_BUTTON_B:
			return "B"
		JOY_BUTTON_X:
			return "X"
		JOY_BUTTON_Y:
			return "Y"
		JOY_BUTTON_LEFT_SHOULDER:
			return "LB"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "RB"
		JOY_BUTTON_LEFT_STICK:
			return "L3"
		JOY_BUTTON_RIGHT_STICK:
			return "R3"
		JOY_BUTTON_BACK:
			return "Select"
		JOY_BUTTON_START:
			return "Start"
		JOY_BUTTON_DPAD_UP:
			return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN:
			return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT:
			return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT:
			return "D-Pad Right"
		_:
			return "Button " + str(button)
