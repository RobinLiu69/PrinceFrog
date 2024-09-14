extends Node

const SLOWNESS_ICON = preload("res://Images/Effects/slowness.png")
const GRASS_ICON = preload("res://Images/Effects/elements/grass.png")
const FIRE_ICON = preload("res://Images/Effects/elements/fire.png")
const WATER_ICON = preload("res://Images/Effects/elements/water.png")
const POISON_ICON = preload("res://Images/Effects/elements/poison.png")
const ELECTRIC_ICON = preload("res://Images/Effects/elements/electric.png")

const ELEMENTS: Array[String] = ["grass", "fire", "water", "poison", "electric"]

func get_damage_multiplier(enemy_type: String) -> int:
	match enemy_type:
		"minion":
			return 4
		"boss":
			return 1
		"elite":
			return 1
		_:
			return 1

func effect_update(body: CharacterBody2D) -> void:
	slowness_update(body)
	effect_display_update(body)

func effect_display_update(body: CharacterBody2D) -> void:
	var effect_display: Marker2D = body.get_node("EffectDisplay")
	var effect_display_children: Array[Node] = effect_display.get_children()
	for i in range(len(effect_display_children)):
		effect_display_children[i].position = Vector2.RIGHT* (body.size/100.0 * 7.5 * i)
	slowness_status_display(body)
	elements_status_display(body)



# Called when the node enters the scene tree for the first time.
func stun(body: CharacterBody2D, duration: float = 0) -> bool:
	if not body.has_node("StunTimer"):
		var stun_timer = Timer.new()
		stun_timer.name = "StunTimer"
		#stun_timer.connect(stun_end)
		return true
	else:
		if body.stun_timer.time_left() < duration:
			body.stun_timer.stop()
			body.stun_timer.set_wait_time(duration)
			body.stun_timer.start()
			return true
		else:
			return false

func slowness_update(body: CharacterBody2D) -> void:
	for slowness_level in body.slowness_record.values():
		body.velocity *= (1 - body.slowness_resistance) * (slowness_level/100.0)
	


func slowness(body: CharacterBody2D, level: int, duration: float, key_name: String = "null") -> Timer:
	if not body.has_node("SlownessTimerList"):
		var node = Node2D.new()
		node.name = "SlownessTimerList"
		body.add_child(node)
		
	var slowness_timer_list: Node2D = body.get_node("SlownessTimerList")
	var slowness_timer = Timer.new()
	
	slowness_timer.name = str(slowness_timer.get_instance_id())+ "-level_" + str(level) + "-duration_" + str(duration)
	if key_name == "null":
		body.slowness_record[slowness_timer.get_instance_id()] = level
	slowness_timer.timeout.connect(slowness_removed.bind(body, slowness_timer))
	slowness_timer.set_wait_time(duration)
	slowness_timer_list.add_child(slowness_timer)
	slowness_timer.start()
	return slowness_timer

func slowness_status_display(body: CharacterBody2D) -> void:
	var effect_display: Marker2D = body.get_node("EffectDisplay")
	var effect_display_children: Array[Node] = effect_display.get_children()
	var slowness_in_display: Array[Node] = effect_display_children.filter(func(child): return "SLOWNESS_ICON" in child.name)
	if not body.slowness_record.is_empty() and len(slowness_in_display) < len(body.slowness_record):
		var slowness_icon: Sprite2D = Sprite2D.new()
		slowness_icon.name = "SLOWNESS_ICON-" + str(slowness_icon.get_instance_id())
		slowness_icon.texture = SLOWNESS_ICON
		effect_display.add_child(slowness_icon)
		slowness_icon.scale = Vector2(0.7, 0.7)

	elif len(slowness_in_display) > len(body.slowness_record):
		effect_display.remove_child(slowness_in_display[-1])

func slowness_removed(body: CharacterBody2D, timer: Timer) -> void:
	body.slowness_record.erase(timer.get_instance_id())
	timer.queue_free()




func element_update() -> void:
	pass

func elements_status_display(body: CharacterBody2D) -> void:
	var effect_display: Marker2D = body.get_node("EffectDisplay")
	var effect_display_children: Array[Node] = effect_display.get_children()
	for element_name in ELEMENTS:
		var elements_in_display: Array[Node] = effect_display_children.filter(func(child): return child.name.split('-')[0].to_lower() in element_name)
		if body.current_elements.has(element_name) and len(elements_in_display) < body.current_elements[element_name]:
			var element_icon: Sprite2D = Sprite2D.new()
			element_icon.name = element_name.to_upper() + "-" + str(element_icon.get_instance_id())
			match element_name:
				"grass":
					element_icon.texture = GRASS_ICON
				"fire":
					element_icon.texture = FIRE_ICON
				"water":
					element_icon.texture = WATER_ICON
				"poison":
					element_icon.texture = POISON_ICON
				"electric":
					element_icon.texture = ELECTRIC_ICON
			effect_display.add_child(element_icon)
			element_icon.scale = Vector2(0.3, 0.3)

		elif not body.current_elements.has(element_name) or len(elements_in_display) > body.current_elements[element_name]:
			if elements_in_display:
				effect_display.remove_child(elements_in_display[-1])

func apply_element_effect_on_attack(attacker: CharacterBody2D, victim: CharacterBody2D, applied_element: String, elemental_stack_count: int, damage_taken: float) -> void:
	if applied_element in ["grass", "fire", "water", "poison", "electric"]:
		for i in range(elemental_stack_count): switch_element(attacker, victim, applied_element)
		
	var current_element_names: Array = victim.current_elements.keys()
	
	if "grass" in current_element_names:
		if victim.current_elements["grass"] == 5 and applied_element == "_grass": AttackFunc.heal(attacker, attacker, damage_taken * 0.75)
		elif victim.current_elements["grass"] <= 5: AttackFunc.heal(attacker, attacker, damage_taken * victim.current_elements["grass"]/20)
	if "fire" in current_element_names:
		victim.healing_efficiency["_fire"] = 10 * victim.current_elements["fire"]
		add_fire_timer(attacker, victim)
	if "water" in current_element_names:
		victim.slowness_record["_water"] = 100 - 10 * victim.current_elements["water"]
	if "poison" in current_element_names:
		victim.physical_defence["_poison"] = 100 - 2 * victim.current_elements["poison"] * get_damage_multiplier(victim.enemy_type)
		victim.elements_defence["_poison"] = 100 - 2 * victim.current_elements["poison"] * get_damage_multiplier(victim.enemy_type)
		add_poison_timer(attacker, victim)
	if "electric" in current_element_names:
		normal_electric(attacker, victim)
		

		
func normal_electric	(attacker: CharacterBody2D, victim: CharacterBody2D):
		var target_list: Array[Node] = AttackFunc.get_target_list(attacker, "not in my group")
		var targets = AttackFunc.find_the_nearest_targets(victim,target_list,victim.current_elements["electric"])
		targets = targets.slice(1, targets.size())
		for target in targets:
			AttackFunc.damage(attacker, target, 0, 0, 0, 0, 0, 0, "electric")	
	

func switch_element(attacker: CharacterBody2D, victim: CharacterBody2D, applied_element: String) -> void:
	if victim.current_elements:
		var current_element_names: Array = victim.current_elements.keys()
		if applied_element in victim.current_elements:
			if victim.current_elements[applied_element] < 5:
				victim.current_elements[applied_element] += 1
				reset_element_timer(victim)
			else:
				match applied_element:
					"grass":
						if not victim.has_node("GrassTimer"):
							trigger_grass_breakthrough(attacker, victim)
					"fire":
						if not victim.has_node("FireTimer"):
							trigger_fire_breakthrough(attacker, victim)
					"water":
						if not victim.has_node("WaterTimer"):
							trigger_water_breakthrough(attacker, victim)
					"poison":
						if not victim.has_node("PoisonTimer"):
							trigger_poison_breakthrough(attacker, victim)
					"electric":
						if not victim.has_node("ElectricTimer"):
							trigger_electric_breakthrough(attacker, victim)
				reset_element_timer(victim)
		else:
			for element_name in current_element_names:
				match element_name:
					"grass":
						if applied_element == "fire":
							fire_reaction(attacker, victim, victim.current_elements["grass"])
							victim.current_elements.erase("grass")
							victim.current_elements[applied_element] = 1
							reset_element_timer(victim)
						elif applied_element in ["poison", "electric"] and len(current_element_names) == 1:
							victim.current_elements[applied_element] = 1
					"fire":
						if applied_element == "water":
							water_reaction(attacker, victim, victim.current_elements["fire"])
							victim.current_elements.erase("fire")
							victim.current_elements[applied_element] = 1
							reset_element_timer(victim)
						elif applied_element in ["poison", "electric"] and len(current_element_names) == 1:
							victim.current_elements[applied_element] = 1
					"water":
						if applied_element == "grass":
							grass_reaction(attacker, victim, victim.current_elements["water"])
							victim.current_elements.erase("water")
							victim.current_elements[applied_element] = 1
							reset_element_timer(victim)
						elif applied_element in ["poison", "electric"] and len(current_element_names) == 1:
							victim.current_elements[applied_element] = 1
					"poison":
						if applied_element in ["grass", "fire", "water"] and len(current_element_names) == 1:
							victim.current_elements[applied_element] = 1
					"electirc":
						if applied_element in ["grass", "fire", "water"] and len(current_element_names) == 1:
							victim.current_elements[applied_element] = 1
				#if applied_element 
				#victim.current_elements[applied_element] = 1
				reset_element_timer(victim)
	else:
		victim.current_elements[applied_element] = 1
		reset_element_timer(victim)
		
func reset_element_timer(victim: CharacterBody2D) -> void:
	var element_timer: Timer = null
	if victim.has_node("ElementTimer"):
		element_timer = victim.get_node("ElementTimer")
	else:
		element_timer = Timer.new()
		element_timer.name = "ElementTimer"
		victim.add_child(element_timer)
	element_timer.one_shot = true
	element_timer.stop()
	element_timer.set_wait_time(3)
	element_timer.timeout.connect(_on_element_timer_timeout.bind(victim, element_timer))
	element_timer.start()

func _on_element_timer_timeout(victim: CharacterBody2D, timer: Timer) -> void:
	if not victim.current_elements.is_empty():
		if timer == null: return	
		for element_name in victim.current_elements.keys():
			victim.current_elements[element_name] -= 1
			match element_name:
				"fire":
					if victim.current_elements[element_name] <= 0:
						victim.healing_efficiency.erase("_fire")
				"water":
					if victim.current_elements[element_name] <= 0:
						victim.slowness_record.erase("_water")
					else:
						victim.slowness_record["_water"] = 100 - 10 * victim.current_elements["water"]
				"poison":
					if victim.current_elements[element_name] <= 0:
						victim.ence.erase("_poison")
						victim.elements_defphysical_defence.erase("_poison")
					else:
						victim.physical_defence["_poison"] = 100 - 2 * victim.current_elements["poison"] * get_damage_multiplier(victim.enemy_type)
						victim.elements_defence["_poison"] = 100 - 2 * victim.current_elements["poison"] * get_damage_multiplier(victim.enemy_type)
			if victim.current_elements[element_name] <= 0:
				victim.current_elements.erase(element_name)
		timer.set_wait_time(1)
		timer.start()
	else:
		timer.queue_free()
	
func grass_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.heal(attacker, attacker, 0, 5 * stack_level)

func fire_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.real_damage(attacker, victim, 0, 1 * stack_level * get_damage_multiplier(victim.enemy_type))

## ALERT: haven't finished
func water_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.reduce_cooldown(attacker, 5 * stack_level)

func add_fire_timer(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	var fire_timer: Timer = null
	if not victim.has_node("_FireTimer"):
		fire_timer = Timer.new()
		fire_timer.name = "_FireTimer"
		victim.add_child(fire_timer)
		fire_timer.stop()
		fire_timer.set_wait_time(1)
		fire_timer.timeout.connect(_on_fire_timer_timeout.bind(attacker, victim, fire_timer))
		fire_timer.start()
	
func _on_fire_timer_timeout(attacker: CharacterBody2D, victim: CharacterBody2D, timer: Timer) -> void:
	if "fire" in victim.current_elements:
		AttackFunc.damage(attacker, victim, 0, 0, victim.max_health * 0.001 * get_damage_multiplier(victim.enemy_type) * victim.current_elements["fire"], 0, 0, 0)
	else:
		timer.queue_free()
	
func add_poison_timer(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	var poison_timer: Timer = null
	if not victim.has_node("_PoisonTimer"):
		poison_timer = Timer.new()
		poison_timer.name = "_PoisonTimer"
		victim.add_child(poison_timer)
		poison_timer.stop()
		poison_timer.set_wait_time(1)
		poison_timer.timeout.connect(_on_poison_timer_timeout.bind(attacker, victim, poison_timer))
		poison_timer.start()
	
func _on_poison_timer_timeout(attacker: CharacterBody2D, victim: CharacterBody2D, timer: Timer) -> void:
	if "poison" in victim.current_elements:
		AttackFunc.damage(attacker, victim, 0, 0, 0, 0, (victim.max_health - victim.current_health) * 0.005 * get_damage_multiplier(victim.enemy_type) * victim.current_elements["poison"], 0)
	else:
		timer.queue_free()

func add_poison_breakthrough_timer(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	var poison_timer: Timer = null
	if not victim.has_node("_PoisonBreakthroughTimer"):
		poison_timer = Timer.new()
		poison_timer.name = "_PoisonBreakthroughTimer"
		victim.add_child(poison_timer)
		poison_timer.stop()
		print("start")
		victim.physical_defence["_poison_breakthrough"] = 100 - 10 * get_damage_multiplier(victim.enemy_type)
		victim.elements_defence["_poison_breakthrough"] = 100 - 10 * get_damage_multiplier(victim.enemy_type)
		poison_timer.set_wait_time(0.75 * get_damage_multiplier(victim.enemy_type))
		poison_timer.timeout.connect(_on_poison_breakthrough_timer_timeout.bind(attacker, victim, poison_timer))
		poison_timer.start()
	
func _on_poison_breakthrough_timer_timeout(attacker: CharacterBody2D, victim: CharacterBody2D, timer: Timer) -> void:
	victim.physical_defence.erase("_poison_breakthrough")
	victim.elements_defence.erase("_poison_breakthrough")
	print("finish")
	timer.queue_free()

## ALERT: haven't finished
func trigger_grass_breakthrough(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	AttackFunc.damage(attacker, victim, 0, victim.max_health * 0.05 * get_damage_multiplier(victim.enemy_type), 0, 0, 0, 0, "_grass")
	add_breakthrough_timer(victim, "Grass")

## ALERT: haven't finished
func trigger_fire_breakthrough(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	AttackFunc.damage(attacker, victim, 0, 0, victim.max_health * 0.05 * get_damage_multiplier(victim.enemy_type), 0, 0, 0, "_fire")
	add_breakthrough_timer(victim, "Fire")

## ALERT: haven't finished
func trigger_water_breakthrough(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	AttackFunc.damage(attacker, victim, 0, 0, 0, victim.max_health * 0.05 * get_damage_multiplier(victim.enemy_type), 0, 0, "_water")
	add_breakthrough_timer(victim, "Water")

## ALERT: haven't finished
func trigger_poison_breakthrough(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	AttackFunc.damage(attacker, victim, 0, 0, 0, 0, victim.max_health * 0.05 * get_damage_multiplier(victim.enemy_type), 0, "_poison")
	add_poison_breakthrough_timer(attacker, victim)											
	add_breakthrough_timer(victim, "Poison")

## ALERT: haven't finished
func trigger_electric_breakthrough(attacker: CharacterBody2D, victim: CharacterBody2D) -> void:
	AttackFunc.damage(attacker, victim, 0, 0, 0, 0, 0, victim.max_health * 0.05 * get_damage_multiplier(victim.enemy_type), "_electric")
	var target_list: Array[Node] = AttackFunc.get_target_list(attacker, "not in my group")
	var targets = AttackFunc.find_the_nearest_targets(victim,target_list,5)
	targets = targets.slice(1, targets.size())
	for target in targets:
		AttackFunc.damage(attacker, target, 0, 0, 0, 0, 0, target.max_health * 0.0025 * get_damage_multiplier(target.enemy_type), "electric")	
	add_breakthrough_timer(victim, "Electric")

func add_breakthrough_timer(body:CharacterBody2D, name:String) -> void:
	var element_timer: Timer = null
	if body.has_node(name+"Timer"):
		element_timer = body.get_node(name+"Timer")
	else:
		element_timer = Timer.new()
		element_timer.name = name+"Timer"
		body.add_child(element_timer)
	element_timer.one_shot = true
	element_timer.stop()
	element_timer.set_wait_time(3)
	element_timer.timeout.connect(element_timer.queue_free)
	element_timer.start()
