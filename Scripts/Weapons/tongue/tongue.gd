extends CharacterBody2D

@export var basic_damage: int
@export var speed: int
@export var radius: float
@export var from: CharacterBody2D = null
@export var target: CharacterBody2D = null
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var tongue_mid: Line2D = $TongueMid

var target_hit: bool = false
var pulled: bool = false
var verify: bool = false


func _ready():
	timer.set_wait_time(0.5)
	timer.start()
	anim.play("attack")

func _process(delta):
	movement(delta)
	move_and_slide()
	
func _on_timer_timeout() -> void:
	hit()
	
func movement(delta: float) -> bool:
	if target and not target_hit:
		if is_instance_valid(target):
			look_at(target.global_position)
			velocity = global_position.direction_to(target.global_position) * speed * 2.5
			return true
		else:
			hit()
	elif target_hit:
		look_at(from.position)
		rotate(PI)
		if not pulled: pull_target()
		velocity = global_position.direction_to(from.global_position) * speed * 2.5
		return true
		
	return false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	hit()

func hit():
	print("hit")
	velocity = Vector2.ZERO
	target_hit = true
	
func pull_target() -> bool:
	if is_instance_valid(target) and verify:
		if from.global_position.distance_squared_to(target.global_position) > (from.size * radius) ** 2:
			target.global_position = global_position
			return true
		else:
			pulled = true
	return false	

func _on_tongue_hit_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and body != from and not target_hit:
		var total_damage = basic_damage
		body.handle_hit(from, total_damage)
		verify = true
		hit()
	elif target_hit and body == from:
		get_parent().tongue_exist = false
		from.anim.play("RESET")
		queue_free()
