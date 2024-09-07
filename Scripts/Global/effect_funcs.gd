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
			body.stun_timer.wait_time(duration)
			body.stun_timer.start()
			return true
		else:
			return false
	
	
	
func slow(body: CharacterBody2D, level: float, duration: float) -> bool:
	var slow_timer = Timer.new()
	body.slow_record.append([level, duration, slow_timer])
	body.add_child(slow_timer)
	
	
	return true

func slow_removed(body: CharacterBody2D, timer: Timer) -> void:
	body.slow_record.remove()
