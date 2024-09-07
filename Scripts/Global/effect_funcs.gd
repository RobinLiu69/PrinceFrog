extends Node


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

func slow_calculate(body: CharacterBody2D) -> void:
	for slow_level in body.slow_record:
		body.velocity *= (1 - body.slow_resistance) * slow_level


func slow(body: CharacterBody2D, level: float, duration: float) -> bool:
	if body.has_node("SlowTimerList"):
		var node = Node2D.new()
		node.name = "SlowTimerList"
		body.add_child(node)
		
	var slow_timer_list: Node2D = body.get_node("SlowTimerList")
	var slow_timer = Timer.new()
	
	slow_timer.name = str(slow_timer.get_instance_id())+ "-level_" + str(level) + "-duration_" + str(duration)
	body.slow_record[slow_timer.get_instance_id()] = level
	slow_timer.timeout.connect(slow_removed.bind(body, slow_timer))
	slow_timer.set_wait_time(duration)
	slow_timer_list.add_child(slow_timer)
	slow_timer.start()
	return true

func slow_removed(body: CharacterBody2D, timer: Timer) -> void:
	body.slow_record.erase(timer.get_instance_id())
	timer.queue_free()
