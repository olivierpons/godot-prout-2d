extends PathFollow2D

@export var speed: float = 0.1

func _process(delta):
	progress_ratio += delta * speed
