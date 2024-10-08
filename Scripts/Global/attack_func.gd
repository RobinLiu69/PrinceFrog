extends Node

const BASIC_ARRAY: Array[String] = ["physical_defence", "elements_resistance", "grass_defence"\
, "fire_defence", "water_defence", "poison_defence", "electric_defence"]

const GROUP_NAMES: Array[String] = ["aggressive", "friendly", "neutral"]


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func find_the_nearest_targets(body: CharacterBody2D, target_list: Array[Node], max_amount: int = 1) -> Array[Node]:
	var valid_targets = []
	for target in target_list:
		if is_instance_valid(target):
			valid_targets.append([body.global_position.distance_squared_to(target.global_position), target])
	valid_targets.sort()
	var nearest_targets: Array[Node] = []
	for i in range(min(max_amount, len(valid_targets))):
		nearest_targets.append(valid_targets[i][1])
	return nearest_targets

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

func heal(source: CharacterBody2D, target: CharacterBody2D, direct_amount: float, max_health_percentage_amount: int = 0) -> float:
	var total_heal_amount: float = 0
	total_heal_amount += direct_amount if direct_amount > 0 else 0
	total_heal_amount += target.max_health * max_health_percentage_amount/100.0 if max_health_percentage_amount > 0 else 0
	target.take_heal(source, round(total_heal_amount))
	return total_heal_amount

func real_damage(attacker: CharacterBody2D, victim:CharacterBody2D, direct_amount: float, max_health_percentage_amount: int = 0) -> float:
	var total_damage_amount: float = 0
	total_damage_amount += direct_amount if direct_amount > 0 else 0
	total_damage_amount += victim.max_health * max_health_percentage_amount/100.0 if max_health_percentage_amount > 0 else 0
	var damage_taken: int = victim.take_damage(attacker, round(total_damage_amount))
	ParticleFunc.display_number(damage_taken, victim.damage_numbers_origin.global_position)
	return total_damage_amount

func damage(attacker: CharacterBody2D, victim: CharacterBody2D, physical_damage: float = 0, grass_damage: float = 0, \
			fire_damage: float = 0, water_damage: float = 0, poison_damage: float = 0, electric_damage: float = 0, \
			applied_element: String = "null", elemental_stack_count: int = 1) -> bool:
	if is_instance_valid(victim) and is_instance_valid(attacker):
		assert(BASIC_ARRAY.filter(func(attr): return attr in victim), " don't have the required variables for all kind of defences")
		var total_damage_amount: float = 0
		var defences: Array[float] = []
		for defence in victim.defences:
			var values: float = defence["basic"]
			for key in defence.keys():
				if key == "basic": continue
				else: values *= defence[key]/100.0
			defences.append(floor(values))
		var physical_defence: int = defences[0]
		var elements_resistance: int = defences[1]
		var grass_defence: int = defences[2]
		var fire_defence: int = defences[3]
		var water_defence: int = defences[4]
		var poison_defence: int = defences[5]
		var electric_defence: int = defences[6]
		
		
		total_damage_amount += physical_damage * (1 - (physical_defence/(physical_defence + 100)))
		total_damage_amount += max(0, element_calculate(grass_damage, elements_resistance) - grass_defence)
		total_damage_amount += max(0, element_calculate(fire_damage, elements_resistance) - fire_defence)
		total_damage_amount += max(0, element_calculate(water_damage, elements_resistance) - water_defence)
		total_damage_amount += max(0, element_calculate(poison_damage, elements_resistance) -poison_defence)
		total_damage_amount += max(0, element_calculate(electric_damage, elements_resistance) - electric_defence)
		
		var element_type: String = "null"
		
		if grass_damage:
			element_type = "grass"
		elif fire_damage:
			element_type = "fire"
		elif water_damage:
			element_type = "water"
		elif poison_damage:
			element_type = "poison"
		elif electric_damage:
			element_type = "electric"
		
		var damage_taken: int = victim.take_damage(attacker, round(total_damage_amount))
		EffectFunc.apply_element_effect_on_attack(attacker, victim, applied_element, elemental_stack_count, damage_taken)
		ParticleFunc.display_number(damage_taken, victim.damage_numbers_origin.global_position, element_type)
		return true
	return false


func element_calculate(damage: int, element_defence: int) -> float:
	return damage * (1 - (element_defence / (100.0 + element_defence)))
