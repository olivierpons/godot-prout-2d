class_name PlayerController
extends CharacterBody2D

# --- Constants ---
const COYOTE_TIME: float = 0.15
const DESCENDING_DELAY: float = 0.2
const DIRECTION_SWITCH_THRESHOLD: float = 10.0
const FLOOR_PUSH: float = 0.1

# --- Exports ---
@export var label_last_modified: Label = null

@export_group("Speed")
@export var max_horizontal_speed: float = 250.0  # Max X speed
@export var max_horizontal_acceleration_time: float = 3.0
@export var deceleration: float = 1000.0
@export var max_jump_time: float = 0.1  # Maximum time for full jump
@export var min_jump_force: float = 80.0  # Minimal jump force
@export var max_jump_force: float = 300.0  # Maximum jump force
@export var gravity: float = 980.0

@export_group("Sounds")
@export var sounds_you_died: Array[AudioStreamMP3]
@export var sounds_jump: Array[AudioStreamMP3]

# --- Public variables ---
var jump_time: float = 0.0
var is_jumping: bool = false
var horizontal_acceleration_time: float = 0.0
var is_accelerating: bool = false
var direction: int = 0
var fall_time: float = 0.0
var can_jump: bool = false
var is_dying: bool = false
var is_waiting_end_level: bool = false
var is_descending: bool = false
var descending_timer: float = 0.0

# --- Onready ---
@onready var ray_cast_1: RayCast2D = $RayCast_1
@onready var ray_cast_2: RayCast2D = $RayCast_2
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_sfx: AudioStreamPlayer2D = $AudioStreamPlayer2DSfx
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var bubble: Node = $Bubble

# For Debug:
@onready var touch_h: Node = $TouchH
@onready var touch_v: Node = $TouchV

# --- Built-in callbacks ---
func _ready() -> void:
	add_to_group("player")
	#if label_last_modified:
	#	global.set_text_to_last_modified(label_last_modified)


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()


func _physics_process(delta: float) -> void:
	#for i: int in get_slide_collision_count():
		#var collision: KinematicCollision2D = get_slide_collision(i)
		#var collider: Object = collision.get_collider()

		# for state machines
		#if collider is TileMap:
		#	var tilemap = collider as TileMap
		#	var collision_point = collision.get_position()
		#	var tile_pos = tilemap.local_to_map(collision_point)
		#	print("tile_pos=", tile_pos)

	_apply_gravity(delta)

	if is_dying or is_waiting_end_level:
		move_and_slide()
		return

	_handle_descending(delta)
	_handle_jump(delta)
	_handle_horizontal_movement(delta)
	_handle_wall_collision(delta)
	_update_sprite_direction()
	_play_animations()
	move_and_slide()

# --- Private methods ---
func _apply_gravity(delta: float) -> void:
	if is_descending or not is_on_floor():
		velocity.y += gravity * delta
		fall_time += delta
		return
	fall_time = 0.0
	can_jump = true
	if descending_timer <= 0.0:
		is_descending = false


func _update_sprite_direction() -> void:
	# Flip the sprite:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


func _play_animations() -> void:
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


func _decelerate_horizontal(delta: float) -> void:
	is_accelerating = false
	horizontal_acceleration_time = 0
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)


func _accelerate_horizontal(delta: float) -> void:
	if not is_accelerating:
		is_accelerating = true
		horizontal_acceleration_time = 0
	else:
		horizontal_acceleration_time = minf(
			horizontal_acceleration_time + delta,
			max_horizontal_acceleration_time
		)

	var acceleration_factor: float = (
		horizontal_acceleration_time / max_horizontal_acceleration_time
	)
	var target_speed: float = max_horizontal_speed * direction
	# Check if the direction has changed
	if sign(velocity.x) != direction:
		# Apply deceleration if changing direction
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		if abs(velocity.x) < DIRECTION_SWITCH_THRESHOLD:
			# A threshold to switch to acceleration
			velocity.x = target_speed * delta
	else:
		# Accelerate towards the target speed
		velocity.x = lerp(velocity.x, target_speed, acceleration_factor)


func _handle_wall_collision(delta: float) -> void:
	if not is_on_wall():
		return
	# For debug:
	# touch_v.visible = is_on_wall()
	# touch_h.visible = is_on_floor()
	# Check for horizontal collisions and reset speed if colliding
	velocity.x = 0
	if abs(velocity.x) > DIRECTION_SWITCH_THRESHOLD:  # He was fast
		horizontal_acceleration_time = maxf(
			0.0, horizontal_acceleration_time - delta
		)
	else:
		horizontal_acceleration_time = 0
	is_accelerating = false

	if is_on_wall() and is_on_floor():
		position.y += FLOOR_PUSH


func _handle_descending(delta: float) -> void:
	# Handle downward movement through the floor
	# touch_h.visible = ray_cast_2d.is_colliding()
	if (
		Input.is_action_pressed("move_down")
		and is_on_floor()
		and not (ray_cast_1.is_colliding() or ray_cast_2.is_colliding())
	):
		is_descending = true
		descending_timer = DESCENDING_DELAY
		body_collision.disabled = true

	if not is_descending:
		return
	body_collision.disabled = true
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	descending_timer -= delta
	if descending_timer <= 0.0 and not is_on_floor():
		is_descending = false
		body_collision.disabled = false


func _handle_jump(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and not is_descending and (
		is_on_floor() or (fall_time < COYOTE_TIME and can_jump)
	):
		global.play_rand_sound(audio_stream_sfx, sounds_jump)
		is_jumping = true
		jump_time = 0

	if Input.is_action_pressed("jump") and is_jumping:
		jump_time += delta
		if jump_time > max_jump_time:
			jump_time = max_jump_time
			is_jumping = false
		else:
			var jump_force: float = lerp(
				min_jump_force, max_jump_force, jump_time / max_jump_time
			)
			velocity.y = -jump_force

	if Input.is_action_just_released("jump"):
		is_jumping = false


func _handle_horizontal_movement(delta: float) -> void:
	# Handle horizontal movement.
	direction = int(round(Input.get_axis("move_left", "move_right")))
	if direction != 0 and not is_descending:
		_accelerate_horizontal(delta)
	else:
		_decelerate_horizontal(delta)


func _on_change_max_horizontal_speed(new_value: float) -> void:
	max_horizontal_speed = new_value


func _on_change_deceleration(new_value: float) -> void:
	deceleration = new_value


func _on_change_max_jump_time(new_value: float) -> void:
	max_jump_time = new_value


func _on_change_min_jump_force(new_value: float) -> void:
	min_jump_force = new_value


func _on_change_max_jump_force(new_value: float) -> void:
	max_jump_force = new_value


func _on_speak(what: String) -> void:
	bubble_talk(what)

# --- Public methods ---
func die() -> void:
	is_dying = true
	animation_player.play("die")
	body_collision.queue_free()
	global.play_rand_sound(audio_stream_sfx, sounds_you_died)
	global.fade_all()
	global.fade_anim_player.play("normal_to_black")


func bubble_talk(text: String) -> void:
	# This will call the setter and display the text
	bubble.text_to_display = text
