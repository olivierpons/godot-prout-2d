extends Panel

var timer = null

func _ready():
	call_deferred("add_timer")

func add_timer():
	timer = Timer.new()
	timer.wait_time = 0.05
	timer.one_shot = true
	timer.connect("timeout", _set_pause_state)
	add_child(timer)

func _on_btn_ok_pressed():
	visible = false

func _on_btn_cancel_pressed():
	visible = false

func _on_visibility_changed():
	if timer:
		timer.stop()
		timer.start()

func _set_pause_state():
	var tree = get_tree()
	if tree:
		tree.paused = visible
