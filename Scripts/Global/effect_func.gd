extends Node

const SLOWNESS_ICON = preload("res://Images/Effects/slowness.png")


func get_damage_multiplier(enemy_type: String) -> int:
	match enemy_type:
		"minion":
			return 3
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
		effect_display_children[i].position = Vector2.RIGHT* (body.size/100 * 7.5 * i)
	slowness_status_display(body)



# Called when the node enters the scene tree for the first time.
func stun(body: CharacterBody2D, duration: float = 0) -> bool:
	if "stun_timer" not in body:
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
		body.velocity *= (1 - body.slowness_resistance) * slowness_level
	


func slowness(body: CharacterBody2D, level: float, duration: float) -> Timer:
	if not body.has_node("SlownessTimerList"):
		var node = Node2D.new()
		node.name = "SlownessTimerList"
		body.add_child(node)
		
	var slowness_timer_list: Node2D = body.get_node("SlownessTimerList")
	var slowness_timer = Timer.new()
	
	slowness_timer.name = str(slowness_timer.get_instance_id())+ "-level_" + str(level) + "-duration_" + str(duration)
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
	if not body.slowness_record.is_empty() and len(effect_display_children) < len(body.slowness_record):
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


func apply_element_effect_on_attack(attacker: CharacterBody2D, victim: CharacterBody2D, applied_element: String) -> void:
	if applied_element != "null":
		switch_element(attacker, victim, applied_element)
	else:
		pass

func switch_element(attacker: CharacterBody2D, victim: CharacterBody2D, applied_element: String) -> void:
	if victim.current_element:
		if applied_element in victim.current_element:
			if victim.current_element[applied_element] < 5:
				victim.current_element[applied_element] += 1
				reset_element_timer(victim)
			else:
				pass
		else:
			match victim.current_element.keys()[0]:
				"grass":
					if applied_element == "fire":
						fire_reaction(attacker, victim, victim.current_element.values()[0])
				"fire":
					if applied_element == "water":
						water_reaction(attacker, victim, victim.current_element.values()[0])
				"water":
					if applied_element == "grass":
						grass_reaction(attacker, victim, victim.current_element.values()[0])
			victim.current_element.clear()
			victim.current_element[applied_element] = 1
			reset_element_timer(victim)
	else:
		victim.current_element[applied_element] = 1
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
	if not victim.current_element.is_empty():
		if timer == null: return
		if victim.current_element.values()[0] < 2:
			victim.current_element.clear()
			timer.queue_free()
		else:
			victim.current_element[victim.current_element.keys()[0]] -= 1
			timer.set_wait_time(1)
			timer.start()
	else:
		victim.remove_child(victim.get_node("ElementTimer"))
	
func grass_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.heal(attacker, attacker, 0, 5 * stack_level)


func fire_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.real_damage(attacker, victim, 0, 1 * stack_level * get_damage_multiplier(victim.enemy_type))

## ALERT: haven't finished
func water_reaction(attacker: CharacterBody2D, victim: CharacterBody2D, stack_level: int) -> void:
	AttackFunc.reduce_cooldown(attacker, 5 * stack_level)
	

#func apply_grass_element(body: CharacterBody2D) -> void:
	#pass
