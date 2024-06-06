extends CharacterBody2D

@export_group("Horizontal")
@export var max_horizontal_speed = 200.0  # Max X speed
@export var max_horizontal_acceleration_time:float = 3.0  # Time to reach max speed
@export var deceleration: float = 1000.0 # Deceleration when speed changes

@export_group("Vertical")
@export var max_jump_time = 0.1 # Maximum time for full jump
@export var min_jump_force: float = 80.0  # Minimal jump force
@export var max_jump_force: float = 300.0  # Maximale jump force
@export var gravity:float = 980.0

@export_group("Sounds: jump and die")
@export var sounds_you_died: Array[AudioStreamMP3]
@export var sounds_jump: Array[AudioStreamMP3]

@onready var animated_sprite = $AnimatedSprite2D

@onready var is_dying: bool = false
@onready var is_waiting_end_level: bool = false

@onready var audio_stream_sfx = $AudioStreamPlayer2DSfx
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

# For Debug:
@onready var touch_h = $TouchH
@onready var touch_v = $TouchV


var jump_time: float = 0.0
var is_jumping: bool = false

var horizontal_acceleration_time: float = 0.0
var is_accelerating: bool = false
var direction: int = 0

func _ready():
	add_to_group("player")

func _input(_event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	#if Input.is_action_just_pressed("move_down"):
	#	position.y += 1000 * delta

	if is_dying or is_waiting_end_level:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		global.play_rand_sound(audio_stream_sfx, sounds_jump)
		is_jumping = true
		jump_time = 0

	if Input.is_action_pressed("jump") and is_jumping:
		jump_time += delta
		if jump_time > max_jump_time:
			jump_time = max_jump_time
			is_jumping = false # Stop jumping after max_jump_time
		else:
			var jump_force = lerp(min_jump_force, max_jump_force, jump_time / max_jump_time)
			velocity.y = -jump_force

	if Input.is_action_just_released("jump"):
		is_jumping = false

	# Handle horizontal movement.
	direction = round(Input.get_axis("move_left", "move_right"))
	if direction != 0:
		if not is_accelerating:
			is_accelerating = true
			horizontal_acceleration_time = 0
		else:
			horizontal_acceleration_time += delta
			if horizontal_acceleration_time > max_horizontal_acceleration_time:
				horizontal_acceleration_time = max_horizontal_acceleration_time

		var acceleration_factor: float = (
			horizontal_acceleration_time / max_horizontal_acceleration_time
		)
		var target_speed: float = max_horizontal_speed * direction
		velocity.x = lerp(velocity.x, target_speed, acceleration_factor)
	else:
		is_accelerating = false
		horizontal_acceleration_time = 0
		if velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	# For debug:
	# touch_v.visible = is_on_wall()
	# touch_h.visible = is_on_floor()
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
		
	if velocity.y < 0.0:
		animated_sprite.play("up")
	elif velocity.y > 0.0:
		animated_sprite.play("down")

	move_and_slide()

func die():
	is_dying = true
	animation_player.play("die")
	collision_shape_2d.queue_free()
	global.play_rand_sound(audio_stream_sfx, sounds_you_died)
	global.fade_all()
	global.fade_anim_player.play("normal_to_black")

