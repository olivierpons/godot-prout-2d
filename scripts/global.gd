extends Node

# (!) When new level, new player, and the player initializes this:
var fade_in_out_anim_player: Node

@export var scenes: Array[PackedScene] = []
@onready var _anim_player := $AnimationPlayer
@onready var _track_1 := $Track1
@onready var _track_2 := $Track2
@onready var audio_current: AudioStreamPlayer = null

var msg_previous: String = ""
func out(msg: String) -> void:
	if msg != msg_previous:
		msg_previous = msg
		print(msg)

var _next_level: int = -1
func go_to_level(
	next_level: int, player: Node=null, door: Node=null
):
	if (next_level < 0) or (next_level >= scenes.size()):
		return
	_next_level = next_level
	Engine.time_scale = 0.4
	if player:
		player.is_waiting_end_level = true
		player.velocity = Vector2(0, 0)
	if door:
		door.audio_stream_player_2d.play()
	fade_in_out_anim_player.animation_finished.connect(
		_on_animation_finished
	)
	fade_in_out_anim_player.play("normal_to_black")

func _on_animation_finished(anim_name):
	if anim_name == "normal_to_black":
		fade_in_out_anim_player.animation_finished.disconnect(
			_on_animation_finished
		)
		Engine.time_scale = 1.0
		get_tree().change_scene_to_packed(scenes[_next_level])

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()

# from https://www.gdquest.com/tutorial/godot/audio/background-music-transition/
# properly adapted!
func crossfade_to(audio_stream: AudioStream) -> void:
	if audio_current == null:  # First time here:
		_track_2.stream = audio_stream
		_anim_player.play("fade_in_only_track_2")
		_track_2.play()
		audio_current = _track_2
	elif audio_current == _track_1:
		_track_2.stream = audio_stream
		_anim_player.play("fade_to_track_2")
		_track_2.play()
		audio_current = _track_2
	else:
		_track_1.stream = audio_stream
		_anim_player.play("fade_to_track_1")
		_track_1.play()
		audio_current = _track_1

func fade_all() -> void:
	_anim_player.play("fade_all")
