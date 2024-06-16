extends Node2D

@onready var game_manager = $GameManager
@onready var player = $Player

func _ready():
	game_manager.all_coins_collected.connect(
		_on_all_coins_collected
	)

func _on_all_coins_collected():
	player.bubble_talk("Now,\nI should\ngo to the\nexit door!")
