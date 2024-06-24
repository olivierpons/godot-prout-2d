extends Node2D

@onready var game_manager = $GameManager
@onready var player = $Player

func _ready():
	await get_tree().process_frame
	game_manager.all_coins_collected.connect(
		_on_all_coins_collected
	)
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = .40
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()

func _on_all_coins_collected():
	player.bubble_talk("Now, I should\ngo to the exit door!")

func _on_timer_timeout() -> void:
	player.bubble_talk("Let's search\nthe gold I deserve!")
