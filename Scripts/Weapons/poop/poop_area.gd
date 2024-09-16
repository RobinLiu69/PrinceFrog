extends CharacterBody2D

@onready var timer: Timer = $Timer

var slowness_time: float 
var slowness_level: float
var existing_time: float = 5
var source: CharacterBody2D = null
var targets: Array = []

var in_slow_targets: Dictionary = {}

func _ready():
	timer.set_wait_time(existing_time)
	timer.start()

func hit(body: CharacterBody2D) -> void:
	if body not in in_slow_targets:
		in_slow_targets[body] = EffectFunc.slowness(body, slowness_level, 10000)
	else:
		in_slow_targets[body].stop()
		in_slow_targets[body].set_wait_time(0.001)
		in_slow_targets[body].start()
	
func _on_poop_area_hit_body_entered(body: Node2D) -> void:
	if body != source and body in targets:
		hit(body)


func _on_poop_area_hit_body_exited(body: Node2D) -> void:
	if body != source and body in targets:
		hit(body)

func _on_timer_timeout() -> void:
	queue_free()
