extends ColorRect

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("black_to_normal")
	visible = true

