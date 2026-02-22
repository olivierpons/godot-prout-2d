class_name TypewriterDisplay
extends Node2D

"""Displays text character by character with sound feedback.

Plays click sounds per character and return sounds on newlines.
Hides itself automatically after the text is fully displayed.
"""

# --- Constants ---
const INTRO_DELAY: float = 0.51
const CHAR_DELAY: float = 0.06
const NEWLINE_DELAY: float = 0.7
const END_PAUSE: float = 1.0

# --- Exports ---
@export var sounds_click: Array[AudioStreamMP3] = []
@export var sounds_return: Array[AudioStreamMP3] = []
@export_multiline var text_to_display: String = "":
	set = _set_text_to_display

# --- Private variables ---
var _is_waiting_end: bool = false
var _audio_players: Array[AudioStreamPlayer2D] = []

# --- Onready ---
@onready var _label: Label = (
	$VBoxContainer/MarginContainer/MarginContainerLabel/Label
)
@onready var _timer: Timer = $Timer
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


# --- Built-in callbacks ---
func _ready() -> void:
	"""Initialize display state."""
	_label.text = ""
	visible = false


# --- Private methods ---
func _set_text_to_display(new_text: String) -> void:
	"""React to text_to_display being set.

	Args:
		new_text: The full string to typewrite.
	"""
	if not is_node_ready():
		return

	text_to_display = new_text
	_label.text = ""
	_is_waiting_end = false
	_animation_player.play("show")
	_timer.wait_time = INTRO_DELAY
	_timer.start()


func _on_timer_timeout() -> void:
	"""Advance the typewriter or trigger the hide animation."""
	if _is_waiting_end:
		_timer.stop()
		_animation_player.play("hide")
		return

	if _label.text != text_to_display:
		_advance_typewriter()
	else:
		_is_waiting_end = true
		_timer.wait_time = END_PAUSE
		_timer.start()


func _advance_typewriter() -> void:
	"""Append the next character and schedule the following tick."""
	var next_index: int = _label.text.length()
	var ch: String = text_to_display.substr(next_index, 1)
	_label.text += ch

	if ch == "\n":
		play_rand_sound(sounds_return)
		_timer.wait_time = NEWLINE_DELAY
	else:
		play_rand_sound(sounds_click)
		_timer.wait_time = CHAR_DELAY

	_timer.start()


func play_rand_sound(sounds: Array[AudioStreamMP3]) -> void:
	"""Play a random sound from the given array on an available player.

	Args:
		sounds: Pool of AudioStreamMP3 to pick from.
	"""
	if sounds.is_empty():
		return

	var player: AudioStreamPlayer2D = _get_available_player()
	player.stream = sounds[randi() % sounds.size()]
	player.play()


func _get_available_player() -> AudioStreamPlayer2D:
	"""Return a free AudioStreamPlayer2D, creating one if needed.

	Returns:
		An AudioStreamPlayer2D not currently playing.
	"""
	for player: AudioStreamPlayer2D in _audio_players:
		if not player.playing:
			return player

	var new_player := AudioStreamPlayer2D.new()
	add_child(new_player)
	_audio_players.append(new_player)
	return new_player


func _on_tree_exiting() -> void:
	sounds_click.clear()
	sounds_return.clear()
