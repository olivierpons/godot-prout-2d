class_name TypewriterDisplay
extends Node2D

"""Displays text character by character with sound feedback.

Plays click sounds per character and return sounds on newlines.

Two modes controlled by wait_for_input:
- false (default): auto-hides after END_PAUSE. Original behavior.
- true: waits for try_advance() calls to progress or dismiss.

Supports multi-page sequences via show_pages().
"""

# --- Signals ---
signal page_finished()
signal all_pages_finished()

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
@export var wait_for_input: bool = false

# --- Private variables ---
var _is_waiting_end: bool = false
var _is_typing: bool = false
var _audio_players: Array[AudioStreamPlayer2D] = []
var _pages: Array[String] = []
var _current_page_index: int = 0

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


# --- Public methods ---
func show_pages(
	pages: Array[String], interactive: bool = true
) -> void:
	"""Start a multi-page dialog sequence.

	Args:
		pages: Array of strings, one per page.
		interactive: If true, waits for try_advance() between pages.
	"""
	if pages.is_empty():
		return
	_pages = pages
	_current_page_index = 0
	wait_for_input = interactive
	# Setting text_to_display triggers the setter which starts typing:
	text_to_display = _pages[0]


func try_advance() -> void:
	"""Advance the display when in wait_for_input mode.

	If still typing, skip to full text.
	If text fully shown, go to next page or dismiss.
	"""
	if not wait_for_input:
		return

	if _is_typing:
		# Skip to end of current page:
		_timer.stop()
		_label.text = text_to_display
		_is_typing = false
		_is_waiting_end = true
		return

	if _is_waiting_end:
		_is_waiting_end = false
		_advance_to_next_page()


func dismiss() -> void:
	"""Force-hide the bubble and reset state."""
	_timer.stop()
	_is_typing = false
	_is_waiting_end = false
	_pages = []
	_current_page_index = 0
	_animation_player.play("hide")


# --- Private methods ---
func _set_text_to_display(new_text: String) -> void:
	"""React to text_to_display being set.

	Assigning inside the setter does NOT re-trigger it in GDScript.

	Args:
		new_text: The full string to typewrite.
	"""
	if not is_node_ready():
		return

	text_to_display = new_text
	_label.text = ""
	_is_waiting_end = false
	_is_typing = true
	_animation_player.play("show")
	_timer.wait_time = INTRO_DELAY
	_timer.start()


func _advance_to_next_page() -> void:
	"""Move to the next page or finish if none left."""
	_current_page_index += 1
	if _current_page_index < _pages.size():
		page_finished.emit()
		# This triggers the setter which restarts typing:
		text_to_display = _pages[_current_page_index]
	else:
		_finish_all_pages()


func _on_timer_timeout() -> void:
	"""Advance the typewriter or trigger end behavior."""
	if _is_waiting_end:
		if wait_for_input:
			_timer.stop()
			return
		_timer.stop()
		_advance_to_next_page()
		return

	if _label.text.length() < text_to_display.length():
		_advance_typewriter()
	else:
		_is_typing = false
		_is_waiting_end = true
		if not wait_for_input:
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


func _finish_all_pages() -> void:
	"""Hide the bubble and emit completion signal."""
	_pages = []
	_current_page_index = 0
	_animation_player.play("hide")
	all_pages_finished.emit()


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
