extends Node

signal next_level(next_level: int, player: Node, door: Node)

# (!) When new level, new player, and the player initializes this:
var fade_anim_player: Node
var mobile_visible: bool = true

@export var scenes: Array[Dictionary] = []

@onready var _anim_player := $AnimationPlayer
@onready var _track_1 := $Track1
@onready var _track_2 := $Track2
@onready var audio_current: AudioStreamPlayer = null

var current_level_index: int = 0

func _ready():
	scenes = [
		{
			"path": "res://scene/levels/level_01.tscn", 
			"message": "",
		},
		{
			"path": "res://scene/levels/level_02_tutorial.tscn", 
			"message": "",
		},
		{
			"path": "res://scene/levels/level_03_tutorial.tscn", 
			"message": "",
		},
		{
			"path": "res://scene/levels/level_02.tscn", 
			"message": "",
		},
		{
			"path": "res://scene/levels/level_03.tscn", 
			"message": "",
		},
		{
			"path": "res://scene/levels/level_04.tscn", 
			"message": "4",
		},
		{
			"path": "res://scene/levels/level_05.tscn", 
			"message": "5",
		},
		{
			"path": "res://scene/levels/level_06.tscn", 
			"message": "6",
		},
		{
			"path": "res://scene/levels/level_07.tscn", 
			"message": "7",
		},
		{
			"path": "res://scene/levels/level_08.tscn", 
			"message": "8",
		},
		{
			"path": "res://scene/levels/level_thibault_01.tscn", 
			"message": "Thibault 1",
		}
	]

var msg_previous: String = ""
func out(msg: String) -> void:
	if msg != msg_previous:
		msg_previous = msg
		print(msg)

func go_to_next_level(player: Node=null, door: Node=null):
	assert(scenes.size() > 0, "No scenes defined")
	current_level_index += 1
	if current_level_index >= scenes.size():
		current_level_index = 0

	var next_scene_obj = scenes[current_level_index]
	var next_scene = load(next_scene_obj["path"])
	assert(next_scene, "Failed to load scene: " + next_scene_obj["path"]			)
	Engine.time_scale = 0.4
	if player:
		player.is_waiting_end_level = true
		player.velocity = Vector2(0, 0)
	if door:
		door.audio_stream_player_exit.play()
	if not fade_anim_player.animation_finished.is_connected(
		_on_animation_finished
	):
		fade_anim_player.animation_finished.connect(
			_on_animation_finished
		)
	fade_anim_player.play("normal_to_black")


func _on_animation_finished(anim_name):
	if anim_name == "normal_to_black":
		fade_anim_player.animation_finished.disconnect(
			_on_animation_finished
		)
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file(scenes[current_level_index]["path"])

func play_rand_sound(audio_stream_player:AudioStreamPlayer2D, tab:Array) -> void:
	var sound:AudioStreamMP3 = tab[randi() % tab.size()]
	audio_stream_player.stream = sound
	audio_stream_player.play()

# from https://www.gdquest.com/tutorial/godot/audio/background-music-transition/
# properly adapted!
func crossfade_to(audio_stream: AudioStream) -> void:
	# return
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

