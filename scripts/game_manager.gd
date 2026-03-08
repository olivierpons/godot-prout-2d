extends Node

signal all_coins_collected()

@export var main_exit_door: Entity

@export var debug: bool = false
@export var audio_stream: AudioStream = null

@onready var timer_open_door: Timer = (
	$TimerOpenDoor
)
@onready var game: Node = $".."
@onready var canvas_layer_for_all: Node = (
	$"../canvas_layer_for_all"
)

var _label_score: Label = null
var to_collect: int = 0

func refresh_collected(
	collected: int = 0,
) -> int:
	to_collect -= collected
	_label_score.text = (
		"Grab " + str(to_collect) + " coin"
	)
	if to_collect > 1:
		_label_score.text += "s"
	elif to_collect == 1:
		_label_score.text += "."
	else:
		_label_score.text = "Find exit now!"
		timer_open_door.start()
		all_coins_collected.emit()
	return to_collect


func _ready() -> void:
	if canvas_layer_for_all:
		canvas_layer_for_all\
			.signal_btn_next_level.connect(
				_on_btn_next_level_released
			)
	else:
		push_error(
			"GameManager: canvas_layer_for_all "
			+ "not found"
		)
	if debug:
		var one_coin_left: bool = false
		for coin: Node in get_tree()\
			.get_nodes_in_group("coin"):
			if not one_coin_left:
				one_coin_left = true
				continue
			coin.queue_free()
	if not audio_stream:
		return
	if not global:
		return
	if not global.has_method("crossfade_to"):
		return

	global.crossfade_to(audio_stream)
	global.fade_anim_player = (
		get_tree().root
			.find_child(
				"canvas_layer_for_all",
				true, false,
			)
			.get_fade_in_out()
			.get_animation_player()
	)
	_label_score = game.find_child(
		"LabelScore", true, false
	)
	call_deferred("_count_coins")


func _count_coins() -> void:
	to_collect = 0
	for coin: Node in get_tree()\
		.get_nodes_in_group("coin"):
		if not coin.is_queued_for_deletion():
			to_collect += 1
	refresh_collected()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()


func _on_timer_open_door_timeout() -> void:
	if (
		main_exit_door
		and main_exit_door.state_door
	):
		main_exit_door.state_door.open()


func _on_btn_next_level_released() -> void:
	global.go_to_next_level()
