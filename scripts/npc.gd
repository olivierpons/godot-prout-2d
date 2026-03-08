class_name Npc
extends Node2D

"""Base class for all NPCs.

Detects player proximity, handles interaction input,
selects the appropriate dialog based on conditions,
and orchestrates page-by-page display via TypewriterDisplay.

To create a new NPC:
1. Instance the npc.tscn base scene (or inherit it).
2. Set the sprite animation.
3. Create NpcDialog resources and assign them to the dialogs array.
That's it. The bubble is a standard dialog_bubble.tscn instance
with wait_for_input enabled automatically during NPC conversations.
"""

signal dialog_started()
signal dialog_ended()
signal item_given(item_id: String, quantity: int)

@export var npc_name: String = "Npc"
@export var dialogs: Array[NpcDialog] = []
@export var idle_animation: String = "idle"

var _player_in_range: bool = false
var _current_dialog: NpcDialog = null
var _is_talking: bool = false
var _used_dialog_ids: Array[String] = []

@onready var _bubble: TypewriterDisplay = $Bubble
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _prompt: Label = $PromptLabel


func _ready() -> void:
	_prompt.visible = false
	_update_prompt_text()
	input_helper.device_changed.connect(_on_device_changed)
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(
		idle_animation
	):
		_sprite.play(idle_animation)
	_bubble.all_pages_finished.connect(_on_all_pages_finished)

func _update_prompt_text() -> void:
	var key: String = input_helper.get_action_label("interact")
	_prompt.text = tr("PROMPT_INTERACT") % key


func _on_device_changed(_is_joypad: bool) -> void:
	_update_prompt_text()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if _is_talking:
		_bubble.try_advance()
		return
	if _player_in_range:
		_start_dialog()


func _on_body_entered(body: Node2D) -> void:
	print(npc_name + ": _on_body_entered")
	if body.is_in_group("player"):
		print(npc_name + ": body.is_in_group(player)")
		_player_in_range = true
		if not _is_talking:
			_prompt.visible = true
	else:
		print(npc_name + ": _player_in_range = false")


func _on_body_exited(body: Node2D) -> void:
	print(npc_name + ": _on_body_exited")
	if body.is_in_group("player"):
		print(npc_name + ":  body.is_in_group(player)")
		_player_in_range = false
		_prompt.visible = false
		if _is_talking:
			print(npc_name + ": _is_talking => _end_dialog()")
			_end_dialog()


func _select_dialog() -> NpcDialog:
	"""Pick the highest-priority valid dialog.

	Returns:
		The best matching NpcDialog, or null if none available.
	"""
	var candidates: Array[NpcDialog] = []
	for d: NpcDialog in dialogs:
		if d.one_shot and d.dialog_id in _used_dialog_ids:
			continue
		if d.required_item != "" and not inventory.has_item(
			d.required_item, d.required_quantity
		):
			continue
		candidates.append(d)

	if candidates.is_empty():
		return null

	candidates.sort_custom(
		func(a: NpcDialog, b: NpcDialog) -> bool:
			return a.priority > b.priority
	)
	return candidates[0]


func _start_dialog() -> void:
	_current_dialog = _select_dialog()
	if not _current_dialog:
		return
	_is_talking = true
	_prompt.visible = false
	dialog_started.emit()
	_bubble.show_pages(
		_current_dialog.pages, true
	)


func _on_all_pages_finished() -> void:
	_end_dialog()


func _end_dialog() -> void:
	if not _is_talking:
		return
	_bubble.dismiss()
	if _current_dialog:
		if _current_dialog.reward_item != "":
			inventory.add_item(
				_current_dialog.reward_item,
				_current_dialog.reward_quantity
			)
			item_given.emit(
				_current_dialog.reward_item,
				_current_dialog.reward_quantity
			)
		if _current_dialog.one_shot and _current_dialog.dialog_id != "":
			_used_dialog_ids.append(_current_dialog.dialog_id)
	_is_talking = false
	_current_dialog = null
	if _player_in_range:
		_prompt.visible = true
	dialog_ended.emit()
