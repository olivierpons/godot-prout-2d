class_name NpcDialog
extends Resource

"""Data container for a single NPC dialog sequence.

Each dialog has multiple pages shown one at a time.
Can require an item to trigger and reward an item on completion.
"""

@export var dialog_id: String = ""
@export_multiline var pages: Array[String] = []

@export_group("Conditions")
@export var required_item: String = ""
@export var required_quantity: int = 1

@export_group("Rewards")
@export var reward_item: String = ""
@export var reward_quantity: int = 1

@export_group("Behavior")
@export var one_shot: bool = false
@export var priority: int = 0  ## Higher priority dialogs are checked first.
