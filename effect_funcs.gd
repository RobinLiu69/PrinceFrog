extends Node


# Called when the node enters the scene tree for the first time.
func stun(vitim: CharacterBody2D, duration: float = 0) -> bool:
	if "stun_timer" not in vitim:
		var stun_timer = Timer.new()
		stun_timer.name = "StunTimer"
		#stun_timer.connect(stun_end)
		return true
	else:
		if vitim.stun_timer.time_left() < duration:
			vitim.stun_timer.stop()
			vitim.stun_timer.wait_time(duration)
			vitim.stun_timer.start()
		else:
			return false
	
	return true
	
	
	
	
	
func slow():
	var slow_timer = Timer.new()
	slow_timer.name = "SlowTimer"
	pass
