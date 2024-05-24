extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@export var sounds_you_won: Array[AudioStreamMP3]
@onready var animated_sprite = $AnimatedSprite2D
@onready var is_dying: bool = false
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dying:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input : direction = -1, 0, 1	
	var direction = Input.get_axis("move_left", "move_right")

	# Flip the sprite:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func play_random_hurt():
	global.play_rand_sound(audio_stream_player_2d, sounds_you_won)
