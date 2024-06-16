extends Node2D

@export_multiline var text_to_display: String = "" : set = _set_text_to_display
@onready var label = $VBoxContainer/MarginContainer/MarginContainerLabel/Label
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _ready():
	label.text = ""
	visible = false

func _set_text_to_display(new_text: String) -> void:
	if not label:
		return
	text_to_display = new_text
	label.text = ""
	animation_player.play("show")
	await animation_player.animation_finished
	timer.start()

func _on_timer_timeout():
	if label.text != text_to_display:
		label.text = text_to_display.substr(0, label.text.length()+1)
		timer.wait_time = 0.05
		timer.start()
	elif timer.wait_time == 1.0:
		timer.stop()
		animation_player.play("hide")
		await animation_player.animation_finished
	else:
		timer.wait_time = 1.0
		timer.start()
