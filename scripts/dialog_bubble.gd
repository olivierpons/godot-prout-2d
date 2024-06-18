extends Node2D

@export var sounds_click: Array[AudioStreamMP3]
@export var sounds_return: Array[AudioStreamMP3]
@export_multiline var text_to_display: String = "" : set = _set_text_to_display
@onready var label = $VBoxContainer/MarginContainer/MarginContainerLabel/Label
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var audio_stream_players = []

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
		var char: String = text_to_display.substr(label.text.length(), 1)
		label.text += char
		if char == "\n":
			play_rand_sound(sounds_return)
			timer.wait_time = 1.05
		else:
			play_rand_sound(sounds_click)
			timer.wait_time = 0.05
		timer.start()
	elif timer.wait_time == 1.0:
		timer.stop()
		animation_player.play("hide")
		await animation_player.animation_finished
	else:
		timer.wait_time = 1.0
		timer.start()

func play_rand_sound(sounds: Array[AudioStreamMP3]):
	# Find an available player or create a new one if all are busy
	var player = get_available_player()
	player.stream = sounds[randi() % sounds.size()]
	player.play()

func get_available_player() -> AudioStreamPlayer2D:
	for player in audio_stream_players:
		if not player.playing:
			return player
	# If no player is available, create a new one
	var new_player = AudioStreamPlayer2D.new()
	add_child(new_player)
	audio_stream_players.append(new_player)
	return new_player
