extends Area2D

@onready var game_manager = $"../../GameManager"
@onready var animation_player = $AnimationPlayer
@export var delay_before_falling: float = 0
@export var falling_speed_gravity: int = 98
@onready var collision_shape_2d = $CollisionShape2D

@onready var timer = $Timer

var velocity: Vector2 = Vector2.ZERO
var is_touching: bool = false

func _ready():
	# (!) this will stop call _physics_process():
	set_physics_process(false)
	if delay_before_falling > 0:
		timer.start(delay_before_falling)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		collision_shape_2d.queue_free()
		animation_player.play("pickup")
		game_manager.add_point()
	else:
		is_touching = true
		velocity = Vector2.ZERO
		falling_speed_gravity = 0

func _physics_process(delta):
	# Appliquer la gravité
	velocity.y += falling_speed_gravity  * delta
	
	# Déplacer l'Area2D selon la vitesse
	position += velocity * delta
	if is_touching:
		position.y -= 0.5

func _on_body_exited(body):
	is_touching = false
	# (!) this will stop call _physics_process():
	set_physics_process(false)

func _on_timer_timeout():
	set_physics_process(true)
