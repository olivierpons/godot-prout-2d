extends Node

# (!) When new level, new player, and the player initializes this:
var fade_in_out_node: Node

@export var scenes: Array[PackedScene] = []
@onready var _anim_player := $AnimationPlayer
@onready var _track_1 := $Track1
@onready var _track_2 := $Track2

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()

# from https://www.gdquest.com/tutorial/godot/audio/background-music-transition/
# properly adapted!
func crossfade_to(audio_stream: AudioStream) -> void:
	if _track_1.playing and _track_2.playing:
		_track_1.stop()
		_track_2.stop()

	if _track_2.playing:
		_track_1.stream = audio_stream
		_track_1.play()
		_anim_player.play("fade_to_track_1")
	else:
		_track_2.stream = audio_stream
		_track_2.play()
		_anim_player.play("fade_to_track_2")


func fade_all() -> void:
	_anim_player.play("fade_all")
