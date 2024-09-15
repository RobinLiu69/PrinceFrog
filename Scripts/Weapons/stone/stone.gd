extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var exisiting_timer: Timer = $ExisitingTimer

var base_damage: int
var physical_damage: int
var speed: float
var existing_time: float
var stun_time: float
var maker: Marker2D = null
var source: CharacterBody2D = null
var targets: Array[Node] = []

func _ready():
	anim.play("attack")
	if existing_time > 0:
		exisiting_timer.set_wait_time(existing_time)
		exisiting_timer.start()
	
	

func _process(delta):
	movement(delta)
	move_and_slide()



func movement(delta: float) -> bool:
	if targets:
		velocity = (Vector2.RIGHT * speed).rotated(rotation) * 2.5
		return true
	return false

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func hit(body: CharacterBody2D) -> void:
	maker.hit_counter()
	velocity = Vector2.ZERO
	anim.play("break", -1., 3)
	targets = []
	await anim.animation_finished
	queue_free()

func stun():
	pass

func _on_stone_body_entered(body: Node2D) -> void:
	if body != source and body in targets:
		var total_damage = base_damage + physical_damage
		AttackFunc.damage(source, body, total_damage)
		hit(body)


func _on_exisiting_timer_timeout() -> void:
	queue_free()
