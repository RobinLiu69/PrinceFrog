extends CharacterBody2D

@export var basic_damage: int = 20
@export var cooldown: float = 1.5
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("enemy")
@onready var timer: Timer = $Timer

var attack_from: CharacterBody2D = null
var in_cooldown: bool = false


func _ready():
	anim.play("RESET")
	pass

func find_nearst_enemy() -> CharacterBody2D:
	var nearst_enemy: CharacterBody2D = null
	var distance: float = INF

	for enemy in enemy_list:
		if global_position.distance_squared_to(enemy.global_position) < distance:
			nearst_enemy = enemy
			distance = global_position.distance_squared_to(enemy.global_position)
	
	return nearst_enemy if nearst_enemy else null
	

func attack(from: CharacterBody2D, damage_info: Array = [0]) -> bool:
	attack_from = from
	if not in_cooldown:
		in_cooldown = true
		timer.set_wait_time(cooldown)
		timer.start()
		
		var nearst_enemy = find_nearst_enemy()
		
		if nearst_enemy != null:
			look_at(nearst_enemy.global_position)
		
		anim.animation_set_next("attack", "RESET")
		anim.play("attack", -1, 1.5)
		return true
	return false

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")


func _on_stick_hit_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and attack_from:
		var total_damage: int = basic_damage
		body.handle_hit(attack_from, total_damage)


func _on_timer_timeout() -> void:
	in_cooldown = false
