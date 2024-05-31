extends Node

@export var audio_stream: AudioStream = null
@onready var label_score = %LabelScore

var to_collect = 0
var exit_door: Node

func refresh_label_score():
	label_score.text = "Grab " + str(to_collect) + " coin"
	if to_collect > 1:
		label_score.text += "s"
	elif to_collect == 1:
		label_score.text += "."
	else:
		label_score.text = "Find exit now!"
		exit_door.open_door()

func _ready():
	if audio_stream:
		global.crossfade_to(audio_stream)
	# (!) initialize global fade_in_out_node each time the player spawns:
	global.fade_in_out_node = get_tree().root.find_child("FadeInOut", true, false)
	to_collect = get_tree().get_nodes_in_group("coin").size()
	exit_door = get_tree().get_nodes_in_group("exit")[0]
	refresh_label_score()
	
func add_point():
	to_collect -= 1
	refresh_label_score()
