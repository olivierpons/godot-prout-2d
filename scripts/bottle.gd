extends Node2D

signal bottle_hit()

@export var sounds_hit: Array[AudioStreamMP3]
@export var explosion: PackedScene
@onready var area_2d = $Area2D
@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.change_max_horizontal_speed.emit(600.0)
		bottle_hit.emit()
		area_2d.queue_free()
		var p = explosion.instantiate()
		p.position = global_position
		p.rotation = global_rotation
		p.emitting = true
		get_tree().current_scene.add_child(p)
		global.play_rand_sound(audio_stream_player, sounds_hit)
		animation_player.play("disappear")
		await animation_player.animation_finished
		queue_free()

