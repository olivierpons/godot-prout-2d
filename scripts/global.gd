extends Node

# (!) the player initialize this:
var fade_in_out_node: Node

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()
