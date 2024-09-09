extends Node

const BASIC_ARRAY: Array[String] = ["physical_defence", "elements_defence", "grass_defence"\
, "fire_defence", "water_defence", "poison_defence", "electric_defence"]

const GROUP_NAMES: Array[String] = ["aggressive", "friendly", "neutral"]


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
	var body_GROUP_NAMES: Array[StringName] = body.get_groups()
	var target_list: Array[Node]
	match target_type:
		"not in my group":
			for group_name in GROUP_NAMES.filter(func(name): return name not in body_GROUP_NAMES):
				target_list += get_tree().get_nodes_in_group(group_name)
			return target_list
		_:
			target_list = get_tree().get_nodes_in_group(target_type)
			return target_list

## ALERT: haven't finished
func reduce_cooldown(target: CharacterBody2D, percentage: int, amount: float = 0) -> void:
	#target.get_node("weapons")
	pass

func heal(source: CharacterBody2D, target: CharacterBody2D, direct_amount: float, percentage_amount: int = 0) -> float:
	var total_heal_amount: float = 0
	total_heal_amount += direct_amount if direct_amount > 0 else 0
	total_heal_amount += target.max_health * percentage_amount/100 if percentage_amount > 0 else 0
	target.take_heal(source, floor(total_heal_amount))
	return total_heal_amount

func real_damage(attacker: CharacterBody2D, victim:CharacterBody2D, direct_amount: float, percentage_amount: int = 0) -> float:
	var total_damage_amount: float = 0
	total_damage_amount += direct_amount if direct_amount > 0 else 0
	total_damage_amount += victim.max_health * percentage_amount/100 if percentage_amount > 0 else 0
	victim.take_damage(attacker, floor(total_damage_amount))
	return total_damage_amount

func damage(attacker: CharacterBody2D, victim: CharacterBody2D, physical_damage: float = 0, grass_damage: float = 0, \
			fire_damage: float = 0, water_damage: float = 0, poison_damage: float = 0, electric_damage: float = 0, \
			applied_element: String = "null") -> bool:
	if is_instance_valid(victim) and is_instance_valid(attacker):
		if BASIC_ARRAY.filter(func(attr): return attr not in victim):
			EffectFunc.apply_element_effect_on_attack(attacker, victim, applied_element)
			var total_damage_amount: float = physical_damage * (1-(victim.physical_defence/(victim.physical_defence+100)))
			total_damage_amount += max(0, grass_damage - (victim.elements_defence + victim.grass_defence))
			total_damage_amount += max(0, fire_damage - (victim.elements_defence + victim.fire_defence))
			total_damage_amount += max(0, water_damage - (victim.elements_defence + victim.water_defence))
			total_damage_amount += max(0, poison_damage - (victim.elements_defence + victim.poison_defence))
			total_damage_amount += max(0, electric_damage - (victim.elements_defence + victim.electric_defence))
			victim.take_damage(attacker, floor(total_damage_amount))
			return true
	return false
