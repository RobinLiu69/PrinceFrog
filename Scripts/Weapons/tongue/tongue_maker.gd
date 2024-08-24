extends Marker2D


@export var basic_damage: int = 0
@export var cooldown: float = 5
@export var speed: float = 500.0
@export var radius: float = 4.00
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("enemy")
@onready var timer: Timer = $Timer


const tongue = preload("res://Scenes/Weapons/tongue/tongue.tscn")

var tongue_exist: bool = false
var in_cooldown: bool = false

func _ready():
	pass
	
func find_nearst_enemy() -> CharacterBody2D:
	var nearst_enemy: CharacterBody2D = null
	var distance: float = INF

	for enemy in enemy_list:
		if global_position.distance_squared_to(enemy.global_position) < distance:
			nearst_enemy = enemy
			distance = global_position.distance_squared_to(enemy.global_position)
	
	return nearst_enemy if is_instance_valid(nearst_enemy) else null

func attack(from: CharacterBody2D, damage_info: Array = [0]) -> bool:
	if not in_cooldown:
		in_cooldown = true
		timer.set_wait_time(cooldown)
		timer.start()
		from.anim.play("open_mouth")
		var scene: Node = get_tree().current_scene
		var tongue_instance = tongue.instantiate()
		var nearst_enemy = find_nearst_enemy()
		
		spawn_projectile(from, tongue_instance, nearst_enemy)
	
	return false

func spawn_projectile(from: CharacterBody2D, instance: CharacterBody2D, nearst_enemy: CharacterBody2D, scene: Node = null) -> bool:
	if nearst_enemy:
		instance.basic_damage = basic_damage
		instance.speed = speed
		instance.radius = radius
		instance.target = nearst_enemy
		instance.from = from
		if scene:
			scene.add_child(instance)
		else:
			add_child(instance)
		instance.global_position = global_position
		return true
	return false

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")


func _on_timer_timeout() -> void:
	in_cooldown = false
