extends ColorRect

@onready var animation_player = $AnimationPlayer

func get_animation_player():
	return find_child("AnimationPlayer", true, false)
	
func _ready():
	animation_player.play("black_to_normal")
	visible = true

