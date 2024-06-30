extends Panel

var timer = null

@onready var btn_ok = $VBoxContainer/hbox_buttons/btn_ok
@onready var checkbox_show_mobile_controls = $VBoxContainer/HBoxContainer/checkbox_show_mobile_controls
@onready var checkbox_flip_controls = $VBoxContainer/hbox_flip_controls/checkbox_flip_controls

func _ready():
	checkbox_show_mobile_controls.button_pressed = global.show_mobile_controls
	checkbox_flip_controls.button_pressed = global.flip_controls
	call_deferred("add_timer")

func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		_on_btn_cancel_pressed()

func add_timer():
	timer = Timer.new()
	timer.wait_time = 0.001
	timer.one_shot = true
	timer.connect("timeout", _timeout_refresh)
	add_child(timer)

func _on_btn_ok_pressed():
	global.show_mobile_controls = checkbox_show_mobile_controls.button_pressed
	global.flip_controls = checkbox_flip_controls.button_pressed
	visible = false

func _on_btn_cancel_pressed():
	visible = false

func _on_visibility_changed():
	if timer:
		timer.stop()
		timer.start()

func _timeout_refresh():
	var tree = get_tree()
	if tree:
		btn_ok.grab_focus()
		tree.paused = visible
