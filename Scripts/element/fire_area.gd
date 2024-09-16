extends CharacterBody2D

@onready var timer: Timer = $Timer

var burn_time: float 
var existing_time: float = 3
var attacker: CharacterBody2D
var targets: Array = []
var in_burn_targets: Dictionary = {}

func _ready():
	timer.set_wait_time(existing_time)
	timer.start()

func hit(body: CharacterBody2D) -> void:
	if body not in in_burn_targets:
		in_burn_targets[body] = AttackFunc.damage(attacker, body, 0, 0, body.max_health * 0.05 * EffectFunc.get_damage_multiplier(body.enemy_type), 0, 0, 0, "fire")
	else:
		in_burn_targets[body].stop()
		in_burn_targets[body].set_wait_time(0.001)
		in_burn_targets[body].start()
	
func _on_fire_area_hit_body_entered(body: Node2D) -> void:
	if body != attacker and body in targets:
		hit(body)


func _on_fire_area_hit_body_exited(body: Node2D) -> void:
	if body != attacker:
		hit(body)

func _on_timer_timeout() -> void:
	queue_free()
