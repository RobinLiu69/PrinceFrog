extends CharacterBody2D

@export var basic_damage: int
@export var speed: float
@export var stun_time: float
@export var from: CharacterBody2D = null
@export var target: CharacterBody2D = null
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	anim.play("attack")

func _process(delta):
	
	movement(delta)
	move_and_slide()
	
	
	
func movement(delta: float) -> bool:
	if target:
		velocity = (Vector2.RIGHT * speed).rotated(rotation) * 2.5
		return true
	return false



func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func hit():
	velocity = Vector2.ZERO
	anim.play("break", -1., 3)
	stun()
	target = null
	await anim.animation_finished
	queue_free()

func stun() -> bool:
	if is_instance_valid(target) and target.has_method("got_stun") and target.has_method("remove_stun"):
		var stun_timer = Timer.new()
		stun_timer.set_wait_time(stun_time * (1 - target.stun_resistance))
		stun_timer.connect("timeout", target.remove_stun)
		target.add_child(stun_timer)
		target.got_stun()
		stun_timer.start()
		return true
	return false

func _on_stone_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and body != from:
		var total_damage = basic_damage
		body.handle_hit(from, total_damage)
		hit()
		
		
 
