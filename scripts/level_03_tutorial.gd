extends Node2D

@onready var game_manager = $GameManager
@onready var player = $Player
@onready var bottle = $Bottle

func _ready():
	await get_tree().process_frame
	bottle.bottle_hit.connect(
		_on_bottle_hit
	)

func _on_bottle_hit():
	player.bubble_talk("I'm GOD!")
