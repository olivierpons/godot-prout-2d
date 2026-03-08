extends Node

"""Inventory autoload singleton.

Manages the player's items as a simple {String: int} dictionary.
Persists across scene changes (autoload).
"""

signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal inventory_changed()

var _items: Dictionary = {}


func add_item(item_id: String, quantity: int = 1) -> void:
	"""Add items to the inventory.

	Args:
		item_id: Unique identifier for the item.
		quantity: Number to add.
	"""
	if _items.has(item_id):
		_items[item_id] += quantity
	else:
		_items[item_id] = quantity
	item_added.emit(item_id, quantity)
	inventory_changed.emit()


func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""Remove items from the inventory.

	Args:
		item_id: Unique identifier for the item.
		quantity: Number to remove.

	Returns:
		True if removal succeeded, false if insufficient quantity.
	"""
	if not has_item(item_id, quantity):
		return false
	_items[item_id] -= quantity
	if _items[item_id] <= 0:
		_items.erase(item_id)
	item_removed.emit(item_id, quantity)
	inventory_changed.emit()
	return true


func has_item(item_id: String, quantity: int = 1) -> bool:
	"""Check if the inventory contains enough of an item.

	Args:
		item_id: Unique identifier for the item.
		quantity: Minimum quantity required.

	Returns:
		True if the inventory has at least quantity of the item.
	"""
	return _items.get(item_id, 0) >= quantity


func get_quantity(item_id: String) -> int:
	"""Get the current quantity of an item.

	Args:
		item_id: Unique identifier for the item.

	Returns:
		The quantity held, or 0 if not present.
	"""
	return _items.get(item_id, 0)


func get_all_items() -> Dictionary:
	"""Return a copy of the full inventory dictionary."""
	return _items.duplicate()


func clear() -> void:
	"""Remove all items from the inventory."""
	_items.clear()
	inventory_changed.emit()
