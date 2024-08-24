extends Marker2D


@export var basic_damage: int = 30
@export var cooldown: float = 10
@export var speed: float = 300.0
@export var stun_time: float = 5
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("enemy")
@onready var timer: Timer = $Timer

const stone = preload("res://Scenes/Weapons/stone/stone.tscn")

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
		
		var scene: Node = get_tree().current_scene
		var stone_instance = stone.instantiate()
		var nearst_enemy = find_nearst_enemy()
		
		spawn_projectile(from, stone_instance, nearst_enemy, scene)
		
	return false

func spawn_projectile(from: CharacterBody2D, instance: CharacterBody2D, nearst_enemy: CharacterBody2D, scene: Node = null) -> bool:
	if nearst_enemy:
		look_at(nearst_enemy.global_position)
		
		instance.basic_damage = basic_damage
		instance.speed = speed
		instance.stun_time = stun_time
		instance.target = nearst_enemy
		instance.from = from
		#---
		instance.rotation = rotation
		#---
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
