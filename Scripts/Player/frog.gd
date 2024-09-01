extends CharacterBody2D

signal health_changed

@export var speed: int = 100.0
@export var size: float = 100.0
@export var max_health: int = 100
@onready var weapons: Array[Node] = ($Weapons).get_children()
@onready var player: AnimatedSprite2D = $Frog
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var current_health: int = max_health


func _ready():
	health_changed.emit()
	# for weapon in weapons:
		# print(weapon.current_scene.scene_file_path)



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
