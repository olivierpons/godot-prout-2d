extends Node2D

@export var next_level: int
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func open_door():
	animation_player.play("open_door")

func _on_body_entered(body):
	if body.is_in_group("player"):
		if animated_sprite_2d.animation == "open":
			Engine.time_scale = 0.4
			body.is_waiting_end_level = true
			body.velocity = Vector2(0, 0)
			audio_stream_player_2d.play()
			var g_animation_player = global.fade_in_out_node.animation_player
			g_animation_player.animation_finished.connect(
				self._on_animation_finished
			)
			g_animation_player.play("normal_to_black")

func _on_animation_finished(anim_name):
	if anim_name == "normal_to_black":
		global.fade_in_out_node.animation_player.animation_finished.disconnect(
			_on_animation_finished
		)
		Engine.time_scale = 1.0
		get_tree().change_scene_to_packed(global.scenes[next_level])
