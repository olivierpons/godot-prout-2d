extends Node

# (!) When new level, new player, and the player initializes this:
var fade_in_out_node: Node

@export var scenes: Array[PackedScene] = []
@onready var _anim_player := $AnimationPlayer
@onready var _track_1 := $Track1
@onready var _track_2 := $Track2
@onready var audio_current: AudioStreamPlayer = null

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()

# from https://www.gdquest.com/tutorial/godot/audio/background-music-transition/
# properly adapted!
func crossfade_to(audio_stream: AudioStream) -> void:
	if audio_current == _track_1:
		print("fade_to_track_2")
		_track_2.stream = audio_stream
		_track_2.play()
		_anim_player.play("fade_to_track_2")
		audio_current = _track_2
	else:
		print("fade_to_track_1")
		_track_1.stream = audio_stream
		_track_1.play()
		_anim_player.play("fade_to_track_1")
		audio_current = _track_1

func fade_all() -> void:
	_anim_player.play("fade_all")
