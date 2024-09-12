extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var tongue_mid: Line2D = $TongueMid

var basic_damage: int
var speed: int
var radius: float
var existing_time: float
var source: CharacterBody2D = null
var maker: Marker2D = null
var targets: Array[Node] = []
var target: CharacterBody2D
var target_hit: bool = false
#var pulled: bool = false


func _ready():
	target = targets[0]
	timer.set_wait_time(existing_time)
	timer.start()
	anim.play("attack")

func _process(delta):
	movement(delta)
	move_and_slide()
	
func _on_timer_timeout() -> void:
	if not target_hit:
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
		look_at(source.position)
		rotate(PI)
		#if not pulled: pull_target()
		velocity = global_position.direction_to(source.global_position) * speed * 2.5
		return true
		
	return false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	hit()

func hit(body: CharacterBody2D = null) -> void:
	target = body
	velocity = Vector2.ZERO
	target_hit = true
	
#func pull_target() -> bool:
	#if is_instance_valid(target)
		#if source.global_position.distance_squared_to(target.global_position) > (source.size * radius) ** 2:
			#target.global_position = global_position
			#return true
		#else:
			#pulled = true
	#return false	
	
func _on_tongue_hit_body_entered(body: Node2D) -> void:
	if body != source and not target_hit: #body.has_method("handle_hit") and 
		var total_damage = basic_damage
		source.anim.play("open_mouth")
		#body.handle_hit(source, total_damage)
		match randi_range(1, 4):
			1:
				AttackFunc.damage(source, body, 5, 0, 0, 0, 0, 0, "grass", 2)
			2:
				AttackFunc.damage(source, body, 5, 0, 0, 0, 0, 0, "fire", 2)
			3:
				AttackFunc.damage(source, body, 5, 0, 0, 0, 0, 0, "water", 2)
			4:
				AttackFunc.damage(source, body, 5, 0, 0, 0, 0, 0, "poison", 2)
		hit(body)
	elif target_hit and body == source:
		source.anim.play("RESET")
		queue_free()
