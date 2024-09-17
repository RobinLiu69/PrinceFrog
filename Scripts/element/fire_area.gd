extends CharacterBody2D

@onready var timer: Timer = $Timer

var burn_time: float = 1
var existing_time: float = 3
var source: CharacterBody2D
var targets: Array = []
var in_burn_targets: Dictionary = {}

func _ready():
	timer.set_wait_time(existing_time)
	timer.start()
	targets = AttackFunc.get_target_list(source, "not in my group")

func hit(body: CharacterBody2D) -> void:
	if body not in in_burn_targets:
		in_burn_targets[body] = burn_timer(source, body)
		print("in")
	else:
		# 停止定时器并移除
		var burn_timer: Timer = in_burn_targets[body] if is_instance_valid(in_burn_targets[body]) else null
		if burn_timer:
			burn_timer.stop()
			burn_timer.queue_free()  # 释放定时器
			in_burn_targets.erase(body)  # 从字典中移除目标
			print("leave")

func _on_fire_area_hit_body_entered(body: Node2D) -> void:
	if body != source and body in targets:
		hit(body)

func _on_fire_area_hit_body_exited(body: Node2D) -> void:
	if body != source and body in in_burn_targets:
		hit(body)

func _on_timer_timeout() -> void:
	queue_free()

func burn_timer(attacker: CharacterBody2D, victim: CharacterBody2D) -> Timer:
	var burn_timer = victim.get_node_or_null("_BurnTimer")
	if not burn_timer:
		burn_timer = Timer.new()
		burn_timer.name = "_BurnTimer"
		victim.add_child(burn_timer)
		burn_timer.stop()
		burn_timer.set_wait_time(1)
		burn_timer.timeout.connect(Callable(self, "_on_burn_timer_timeout").bind(attacker, victim, burn_timer))  
		burn_timer.start()
	return burn_timer

func _on_burn_timer_timeout(attacker: CharacterBody2D, victim: CharacterBody2D, timer: Timer):
	if victim in in_burn_targets:
		EffectFunc.switch_element(attacker, victim, "fire")

	
		
