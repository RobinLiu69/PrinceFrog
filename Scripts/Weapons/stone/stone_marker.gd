extends Marker2D


@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("Enemy")


func _ready():
	enemy_list = get_tree().get_nodes_in_group("enemy")



func find_nearst_enemy() -> CharacterBody2D:
	var nearst_enemy: CharacterBody2D = null
	var distance: float = INF

	for enemy in enemy_list:
		if global_position.distance_squared_to(enemy.global_position) < distance:
			nearst_enemy = enemy
			distance = global_position.distance_squared_to(enemy.global_position)
			print(nearst_enemy)
	
	return nearst_enemy if nearst_enemy else null

func attack() -> bool:
	var scene: Node = get_tree().current_scene
	var stone = preload("res://Scenes/Weapons/stone/stone.tscn")
	var stone_instance = stone.instantiate()
	var nearst_enemy = find_nearst_enemy()
	
	if nearst_enemy:
		look_at(nearst_enemy.global_position)
		stone_instance.rotation = rotation
		stone_instance.target = true
		stone_instance.from = get_parent().get_parent()
		scene.add_child(stone_instance)
		stone_instance.global_position = global_position
		return true
	
	return false


func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")
