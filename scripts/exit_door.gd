extends Node2D

@export var next_level: PackedScene = null
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var audio_stream_open_door = $AudioStreamOpenDoor
@onready var audio_stream_player_exit = $AudioStreamPlayerExit

func _ready():
	assert(next_level != null, "Need next_level!")

func open_door():
	if not gpu_particles_2d.emitting:
		gpu_particles_2d.emitting = true
		animation_player.play("open_door")

func call_global_next_level(player: Node2D=null):
	global.go_to_level(next_level, player, self)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		if animated_sprite_2d.animation == "open":
			call_global_next_level(body)

func _input(_event):
	if Input.is_action_just_pressed("next_level"):
		call_global_next_level()
