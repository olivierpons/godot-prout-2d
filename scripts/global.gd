extends Node

# (!) When new level, new player, and the player initializes this:
var fade_in_out_node: Node

@export var scenes: Array[PackedScene] = []

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()
