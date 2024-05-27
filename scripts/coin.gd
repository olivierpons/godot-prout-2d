extends Area2D

@onready var game_manager = $"../../GameManager"
@onready var animation_player = $AnimationPlayer
@export var is_falling_at_start: bool = true

var custom_gravity : float = 98
var velocity: Vector2 = Vector2.ZERO
var is_touching: bool = false

func _ready():
	if not is_falling_at_start:
		# (!) hint: stop calling _physics_process():
		set_physics_process(false)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		animation_player.play("pickup")
		game_manager.add_point()
	else:
		is_touching = true
		velocity = Vector2.ZERO
		custom_gravity = 0

func _physics_process(delta):
	# Appliquer la gravité
	velocity.y += custom_gravity  * delta
	
	# Déplacer l'Area2D selon la vitesse
	position += velocity * delta
	if is_touching:
		position.y -= 0.5


func _on_body_exited(body):
	is_touching = false
	# (!) hint: stop calling _physics_process():
	set_physics_process(false)
