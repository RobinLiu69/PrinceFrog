extends Node

const SLOWNESSICON = preload("res://Images/Effects/slowness.png")


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

func slowness_status_display(body:CharacterBody2D) -> void:
	var effect_display: Marker2D = body.get_node("EffectDisplay")
	var effect_display_children: Array[Node] = effect_display.get_children()
	var slowness_in_display: Array[Node] = effect_display_children.filter(func(child): return "SlownessIcon" in child.name)
	if not body.slowness_record.is_empty() and len(effect_display_children) < len(body.slowness_record):
		var slowness_icon: Sprite2D = Sprite2D.new()
		slowness_icon.name = "SlownessIcon-" + str(slowness_icon.get_instance_id())
		slowness_icon.texture = SLOWNESSICON
		effect_display.add_child(slowness_icon)
		slowness_icon.scale = Vector2(0.7, 0.7)

	elif len(slowness_in_display) > len(body.slowness_record):
		effect_display.remove_child(slowness_in_display[-1])

func slowness_removed(body: CharacterBody2D, timer: Timer) -> void:
	body.slowness_record.erase(timer.get_instance_id())
	timer.queue_free()
