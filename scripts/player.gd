extends CharacterBody2D

signal change_max_horizontal_speed(new_value: float)
signal change_max_horizontal_acceleration_time(new_value: float)
signal change_deceleration(new_value: float)
signal change_max_jump_time(new_value: float)
signal change_min_jump_force(new_value: float)
signal change_max_jump_force(new_value: float)
signal speak(what: String)

@export var label_last_modified: Label = null

@export_group("Speed")
@export var max_horizontal_speed = 250.0  # Max X speed
@export var max_horizontal_acceleration_time:float = 3.0  # Time to reach max speed
@export var deceleration: float = 1000.0 # Deceleration when speed changes
@export var max_jump_time = 0.1 # Maximum time for full jump
@export var min_jump_force: float = 80.0  # Minimal jump force
@export var max_jump_force: float = 300.0  # Maximale jump force
@export var gravity:float = 980.0
@onready var ray_cast_1 = $RayCast_1
@onready var ray_cast_2 = $RayCast_2


@export_group("Sounds")
@export var sounds_you_died: Array[AudioStreamMP3]
@export var sounds_jump: Array[AudioStreamMP3]

@onready var animated_sprite = $AnimatedSprite2D

@onready var is_dying: bool = false
@onready var is_waiting_end_level: bool = false

@onready var audio_stream_sfx = $AudioStreamPlayer2DSfx
@onready var animation_player = $AnimationPlayer

@onready var body_collision = $BodyCollision
@onready var bubble = $Bubble

# For Debug:
@onready var touch_h = $TouchH
@onready var touch_v = $TouchV


var jump_time: float = 0.0
var is_jumping: bool = false
var horizontal_acceleration_time: float = 0.0
var is_accelerating: bool = false
var direction: int = 0
var fall_time: float = 0.0
var can_jump: bool = false

var is_descending: bool = false
var descending_timer: float = 0.0
var descending_delay: float = 0.2

func _ready():
	add_to_group("player")
	#if label_last_modified:
	#	global.set_text_to_last_modified(label_last_modified)

func _input(_event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	# Add the gravity.
	if is_descending or not is_on_floor():
		velocity.y += gravity * delta
		fall_time += delta
	else:
		fall_time = 0.0
		can_jump = true
		if descending_timer <= 0.0:
			is_descending = false

	if is_dying or is_waiting_end_level:
		move_and_slide()
		return

	# Handle downward movement through the floor
	# touch_h.visible = ray_cast_2d.is_colliding()
	if (
		Input.is_action_pressed("move_down")
		and is_on_floor() 
		and not (ray_cast_1.is_colliding() or ray_cast_2.is_colliding())
	):
		is_descending = true
		descending_timer = descending_delay
		body_collision.disabled = true

	if is_descending:
		body_collision.disabled = true
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		descending_timer -= delta
		if descending_timer <= 0.0 and not is_on_floor():
			is_descending = false
			body_collision.disabled = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and not is_descending and (
		is_on_floor() or (fall_time < 0.15 and can_jump)
	):
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
	if direction != 0 and not is_descending:
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
		# Check if the direction has changed
		if sign(velocity.x) != direction:
			# Apply deceleration if changing direction
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
			if abs(velocity.x) < 10.0:  # A threshold to switch to acceleration
				velocity.x = target_speed * delta
		else:
			# Accelerate towards the target speed
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
	body_collision.queue_free()
	global.play_rand_sound(audio_stream_sfx, sounds_you_died)
	global.fade_all()
	global.fade_anim_player.play("normal_to_black")

func bubble_talk(text: String) -> void:
	# This will call the setter and display the text
	bubble.text_to_display = text

func _on_change_max_horizontal_speed(new_value: float):
	max_horizontal_speed = new_value

func _on_change_max_horizontal_acceleration_time(new_value: float):
	max_horizontal_acceleration_time = new_value

func _on_change_deceleration(new_value: float):
	deceleration = new_value

func _on_change_max_jump_time(new_value: float):
	max_jump_time = new_value

func _on_change_min_jump_force(new_value: float):
	min_jump_force = new_value

func _on_change_max_jump_force(new_value: float):
	max_jump_force = new_value

func _on_speak(what: String):
	bubble_talk(what)


func _on_input_event(viewport, event, shape_idx):
	print(viewport, event, shape_idx)
