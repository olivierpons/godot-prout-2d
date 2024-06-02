extends Node

@export var debug: bool = false
@export var audio_stream: AudioStream = null
@onready var timer_open_door = $TimerOpenDoor

var _label_score: Label = null
var to_collect = 0
var exit_door: Node

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
	_label_score = player.find_child("LabelScore", true, false)
	to_collect = 0
	for coin in get_tree().get_nodes_in_group("coin"):
		if not coin.is_queued_for_deletion():
			to_collect += 1
	exit_door = get_tree().get_nodes_in_group("exit")[0]
	refresh_collected()


func _on_timer_open_door_timeout():
	exit_door.open_door()
