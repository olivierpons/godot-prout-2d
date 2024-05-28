extends CharacterBody2D

const MAX_HORIZONTAL_SPEED = 200.0 # Vitesse maximale en X
const MAX_HORIZONTAL_ACCELERATION_TIME = 3.0 # Temps pour atteindre la vitesse maximale
const DECELERATION = 1000.0 # Vitesse de déccélération lorsque la direction change
const JUMP_VELOCITY = -300.0

@export var audio_stream: AudioStream = null
@export var sounds_you_died: Array[AudioStreamMP3]
@export var sounds_jump: Array[AudioStreamMP3]
@onready var animated_sprite = $AnimatedSprite2D

@onready var is_dying: bool = false
@onready var is_waiting_end_level: bool = false

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_jump_time = 0.1 # Maximum time for full jump
var min_jump_force: int = 80 # Minimal jump force
var max_jump_force: int = 300 # Maximale jump force
var jump_time: float = 0.0
var is_jumping: bool = false

var horizontal_acceleration_time: float = 0.0
var is_accelerating: bool = false
var direction: int = 0

func _ready():
	add_to_group("player")
	if audio_stream:
		global.crossfade_to(audio_stream)
	# (!) initialize global fade_in_out_node each time the player spawns:
	global.fade_in_out_node = get_tree().root.find_child("FadeInOut", true, false)

func _input(_event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dying or is_waiting_end_level:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		global.play_rand_sound(audio_stream_player_2d, sounds_jump)
		is_jumping = true
		jump_time = 0

	if Input.is_action_pressed("jump") and is_jumping:
		jump_time += delta
		if jump_time > max_jump_time:
			jump_time = max_jump_time
			is_jumping = false # Stop jumping after max_jump_time
		else:
			var jump_force = lerp(float(min_jump_force), float(max_jump_force), jump_time / max_jump_time)
			velocity.y = -jump_force

	if Input.is_action_just_released("jump"):
		is_jumping = false

	# Handle horizontal movement.
	direction = int(Input.get_axis("move_left", "move_right"))

	if direction != 0:
		if not is_accelerating:
			is_accelerating = true
			horizontal_acceleration_time = 0
		else:
			horizontal_acceleration_time += delta
			if horizontal_acceleration_time > MAX_HORIZONTAL_ACCELERATION_TIME:
				horizontal_acceleration_time = MAX_HORIZONTAL_ACCELERATION_TIME

		var acceleration_factor: float = (
			horizontal_acceleration_time / MAX_HORIZONTAL_ACCELERATION_TIME
		)
		var target_speed: float = MAX_HORIZONTAL_SPEED * direction
		velocity.x = lerp(velocity.x, target_speed, acceleration_factor)
	else:
		is_accelerating = false
		horizontal_acceleration_time = 0

		if velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Check for horizontal collisions and reset speed if colliding
	if is_on_wall():
		velocity.x = 0

	if is_on_wall() and is_on_floor():
		position.y += .1

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
	#else:
	#	animated_sprite.play("jump")
		
	if velocity.y < 0.0:
		animated_sprite.play("up")
	elif velocity.y > 0.0:
		animated_sprite.play("down")

	move_and_slide()

func die():
	is_dying = true
	animation_player.play("die")
	collision_shape_2d.queue_free()
	global.play_rand_sound(audio_stream_player_2d, sounds_you_died)
	global.fade_all()
	global.fade_in_out_node.animation_player.play("normal_to_black")

