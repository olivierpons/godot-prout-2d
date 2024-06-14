@tool
extends Node

signal coin_collected()

@export var main_exit_door: Node

@export var debug: bool = false
@export var audio_stream: AudioStream = null

@onready var timer_open_door = $TimerOpenDoor
@onready var game = $".."
@onready var canvas_layer_for_all = $"../canvas_layer_for_all"

var _label_score: Label = null
var to_collect = 0

func refresh_collected(collected: int=0) -> int:
	to_collect -= collected
	_label_score.text = "Grab " + str(to_collect) + " coin"
	if to_collect > 1:
		_label_score.text += "s"
	elif to_collect == 1:
		_label_score.text += "."
	else:
		_label_score.text = "Find exit now!"
		timer_open_door.start()
	return to_collect 

func _ready():
	if canvas_layer_for_all:
		canvas_layer_for_all.signal_btn_next_level.connect(
			_on_btn_next_level_released
		)
	if debug:
		var one_coin_left = false
		for coin in get_tree().get_nodes_in_group("coin"):
			if not one_coin_left:
				one_coin_left = true
				continue
			coin.queue_free()
	if audio_stream:
		global.crossfade_to(audio_stream)
	# (!) initialize global fade_in_out_node each time the player spawns:
	var player: Node = get_tree().root.find_child("Player", true, false)
	global.fade_anim_player = (
		player
			.find_child("FadeInOut", true, false)
			.find_child("AnimationPlayer", true, false)
	)
	_label_score = game.find_child("LabelScore", true, false)
	call_deferred("_count_coins")

func _count_coins():
	to_collect = 0
	for coin in get_tree().get_nodes_in_group("coin"):
		if not coin.is_queued_for_deletion():
			to_collect += 1
	refresh_collected()

func _input(event):
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()

func _on_timer_open_door_timeout():
	if main_exit_door:
		main_exit_door.open_door()

func _on_btn_next_level_released():
	global.next_level.emit(
		main_exit_door.next_level, null, main_exit_door
	)
