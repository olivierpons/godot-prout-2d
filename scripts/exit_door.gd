extends Node2D

@export var next_level: int
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var audio_stream_open_door = $AudioStreamOpenDoor
@onready var audio_stream_player_exit = $AudioStreamPlayerExit

func open_door():
	if not gpu_particles_2d.emitting:
		gpu_particles_2d.emitting = true
		animation_player.play("open_door")

func _on_body_entered(body):
	if body.is_in_group("player"):
		if animated_sprite_2d.animation == "open":
			global.go_to_level(next_level, body, self)

func _physics_process(_delta):
	if Input.is_action_just_pressed("next_level"):
		global.go_to_level(next_level, null, self)
