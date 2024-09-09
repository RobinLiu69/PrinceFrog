extends Node

const BASIC_ARRAY: Array[String] = ["physical_defence", "elements_defence", "grass_defence"\
, "fire_defence", "water_defence", "poison_defence", "electric_defence"]

const group_names: Array[String] = ["aggressive", "friendly", "neutral"]


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func find_the_nearest_target(body: CharacterBody2D, target_list: Array[Node]) -> CharacterBody2D:
	var nearest_target: CharacterBody2D = null
	var distance: float = INF
	
	for target in target_list:
		if body.global_position.distance_squared_to(target.global_position) < distance:
			nearest_target = target
			distance = body.global_position.distance_squared_to(target.global_position)
	
	return nearest_target if is_instance_valid(nearest_target) else null

func find_the_farthest_target(body: CharacterBody2D, target_list: Array[Node]) -> CharacterBody2D:
	var farthest_target: CharacterBody2D = target_list.pick_random()
	var distance: float = body.global_position.distance_squared_to(farthest_target.global_position)
	for target in target_list:
		if body.global_position.distance_squared_to(target.global_position) > distance:
			farthest_target = target
			distance = body.global_position.distance_squared_to(target.global_position)
	
	return farthest_target if is_instance_valid(farthest_target) else null

func find_random_target(target_list: Array[Node]) -> CharacterBody2D:
	return target_list.pick_random()

func get_target_list(body: CharacterBody2D, target_type: String) -> Array[Node]:
	var body_group_names: Array[StringName] = body.get_groups()
	var target_list: Array[Node]
	match target_type:
		"not in my group":
			for group_name in group_names.filter(func(name): return name not in body_group_names):
				target_list += get_tree().get_nodes_in_group(group_name)
			return target_list
		_:
			target_list = get_tree().get_nodes_in_group(target_type)
			return target_list

func damage(attacker: CharacterBody2D, victim: CharacterBody2D, physical_damage: float = 0.0, grass_damage: float = 0.0\
, fire_damage: float = 0.0, water_damage: float = 0.0, poison_damage: float = 0.0, electric_damage: float = 0.0) -> bool:
	if is_instance_valid(victim) and is_instance_valid(attacker):
		if BASIC_ARRAY.filter(func(attr): return attr not in victim):
			var value = physical_damage * (1-(victim.armor_class/(victim.armor_class+100)))
			

	return true
