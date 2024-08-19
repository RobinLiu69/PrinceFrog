extends CharacterBody2D

signal health_changed

@export var speed: float = 50.0
@export var max_health: int = 100
@export var stun_resistance: float = 0
@onready var weapons: Array[Node] = ($Weapons).get_children()
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Mouse
@onready var current_health: int = max_health
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("enemy")
@onready var player_chase = false
var player = null

func _ready():
	health_changed.emit()

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")
	movement(delta)

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body not in enemy_list:
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body not in enemy_list:
		player = null
		player_chase = false
		
func remove_stun() -> bool:
	print("stun end")
	anim.play("RESET")
	return true

func got_stun() -> bool:
	print("stun")
	anim.play("stun")
	player = null
	player_chase = false
	return true


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
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 15 * delta)
		velocity.y = move_toward(velocity.y, 0, speed * 15 * delta)
		
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
	
	return true
	
