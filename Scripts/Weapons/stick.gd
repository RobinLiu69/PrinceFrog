extends CharacterBody2D

@export var basic_damage: int = 10
@export var cooldown: int = 1500
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("Enemy")

func _ready():
	anim.play("RESET")
	pass

func find_nearst_enemy() -> CharacterBody2D:
	var nearst_enemy: CharacterBody2D = null
	var distance: float = INF

	for enemy in enemy_list:
		print(global_position.distance_squared_to(enemy.global_position), ",", distance)
		if global_position.distance_squared_to(enemy.global_position) < distance:
			nearst_enemy = enemy
			distance = global_position.distance_squared_to(enemy.global_position)
			print(nearst_enemy)
	
	return nearst_enemy if nearst_enemy else null
	

func attack() -> bool:
	
	var nearst_enemy = find_nearst_enemy()
	
	if nearst_enemy != null:
		look_at(nearst_enemy.global_position)
	
	
	anim.animation_set_next("attack", "RESET")
	anim.play("attack", -1, 1.5)
	return false

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")
	
	pass

func _on_stick_hit_body_entered(body):
	if body.has_method("handle_hit"):
		var total_damage: int = basic_damage
		body.handle_hit(get_parent().get_parent(), total_damage)
