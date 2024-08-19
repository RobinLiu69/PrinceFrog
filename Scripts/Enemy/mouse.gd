extends CharacterBody2D

signal health_changed

@export var speed: float = 50.0
@onready var weapons: Array[Node] = ($Weapons).get_children()
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Mouse
@export var max_health: int = 100
@onready var current_health: int = max_health
@onready var player_chase = false
var player = null

func _ready():
	health_changed.emit()
	pass

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func handle_hit(attacker: CharacterBody2D, damage: int) -> bool:
	current_health -= damage
	health_changed.emit()
	if not alive():
		queue_free()
		print(sprite.name +" dead")
	return true
	
func alive() -> bool:
	return current_health > 0

func movement(delta: float) -> bool:
	if player_chase:
		velocity = position.direction_to(player.position) * speed * 2.5
		anim.play("walk")
		print("chasing")
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 15 * delta)
		velocity.y = move_toward(velocity.y, 0, speed * 15 * delta)
		
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
	
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement(delta)

	move_and_slide()
