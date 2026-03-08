extends Area2D

"""Triggers all coins in the scene to start falling.

When the player enters this Area2D, finds all
nodes in the 'coin' group and calls
start_falling() on their Collectible component.
"""


func _on_body_entered(_body: Node2D) -> void:
	for coin: Node in get_tree().get_nodes_in_group("coin"):
		if not coin is Entity:
			continue
		var entity: Entity = coin as Entity
		if entity.collectible:
			entity.collectible.start_falling()
