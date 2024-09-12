extends CharacterBody2D

signal health_changed

@export var speed: float = 50.0
@export var max_health: int = 500
@export var size: float = 70.0
@export var slowness_resistance: float = 0
@export var stun_resistance: float = 0
@onready var weapons: Array[Node] = ($Weapons).get_children()
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Mouse
@onready var current_health: int = max_health
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("aggressive")
@onready var player_chase: bool = false
@onready var damage_numbers_origin: Node2D = $DamageNumbersOrigin
var player: CharacterBody2D = null


var enemy_type: String = "boss" # minion/boss/elite/frog
var current_elements: Dictionary = {}
var slowness_record: Dictionary = {}
var healing_efficiency: Dictionary = {"basic": 100}


var physical_defence: Dictionary = {"basic": 0}
var elements_defence: Dictionary = {"basic": 15}
var grass_defence: Dictionary = {"basic": 0}
var fire_defence: Dictionary = {"basic": 0}
var water_defence: Dictionary = {"basic": 10}
var poison_defence: Dictionary = {"basic": 0}
var electric_defence: Dictionary = {"basic": 0}
var defences: Array[Dictionary] = [physical_defence, elements_defence, grass_defence, fire_defence, water_defence, poison_defence, electric_defence]

func _ready():
	health_changed.emit()

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("aggressive")
	movement(delta)

	EffectFunc.effect_update(self)
	
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


#func handle_hit(attacker: CharacterBody2D, damage: int) -> bool:
	#current_health -= damage
	#health_changed.emit()
	#if not alive():
		#queue_free()
		#print(sprite.name +" dead")
	#return true

func take_damage(attacker: CharacterBody2D, value: int) -> float:
	value = current_health if current_health - value <= 0 else value
	current_health -= value
	health_changed.emit()
	if not alive():
		queue_free()
		print(sprite.name +" dead")
	return value

func take_heal(source: CharacterBody2D, value: int) -> float:
	for i in healing_efficiency.keys():
		value *= healing_efficiency[i]/100
	value = max_health - current_health if current_health + value >= max_health else value
	current_health -= value
	return value

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
	
