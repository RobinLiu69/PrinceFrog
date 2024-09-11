extends CharacterBody2D

signal health_changed

@export var speed: int = 100.0
@export var size: float = 100.0
@export var max_health: int = 100
@onready var weapons: Array[Node] = ($Weapons).get_children()
@onready var player: AnimatedSprite2D = $Frog
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var current_health: int = max_health

var enemy_type: String = "frog" # minion/boss/elite/frog
var current_elements: Dictionary = {}
var slowness_record: Dictionary = {}
var healing_efficiency: Dictionary = {"basic": 100}

var physical_defence: int = 0
var elements_defence: int = 0
var grass_defence: int = 0
var fire_defence: int = 0
var water_defence: int = 0
var poison_defence: int = 0
var electric_defence: int = 0

func _ready():
	health_changed.emit()
	# for weapon in weapons:
		# print(weapon.current_scene.scene_file_path)

func take_damage(attacker: CharacterBody2D, value: int) -> float:
	value = current_health if current_health - value <= 0 else value
	current_health -= value
	health_changed.emit()
	if not alive():
		queue_free()
		print(name +" dead")
	return value

func take_heal(source: CharacterBody2D, value: int) -> float:
	for i in healing_efficiency.keys():
		value *= healing_efficiency[i]/100
	print(value)
	value = max_health - current_health if current_health + value >= max_health else value
	current_health -= value
	return value

func get_input() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")


func movement(delta: float) -> bool:
	var direction: Vector2 = get_input()
	if direction:
		velocity = direction * speed * 2.5
		
		if velocity.x < 0:
			player.flip_h = true
		elif velocity.x > 0:
			player.flip_h = false

		return true
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 15 * delta)
		velocity.y = move_toward(velocity.y, 0, speed * 15 * delta)
		return false

func handle_hit(attacker: CharacterBody2D, damage: int) -> bool:
	current_health -= damage
	health_changed.emit()
	return true


func alive() -> bool:
	return current_health > 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("e"):
		for weapon in weapons:
			if weapon.has_method("attack"):
				weapon.attack(self)


func _physics_process(delta: float):
	movement(delta)
	move_and_slide()
