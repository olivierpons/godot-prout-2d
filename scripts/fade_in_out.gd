extends ColorRect

signal on_transition_finished

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("black_to_normal")
	visible = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "normal_to_black":
		on_transition_finished.emit()
