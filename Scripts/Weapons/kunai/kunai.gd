extends CharacterBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var exisiting_timer: Timer = $ExisitingTimer

var basic_damage: int
var speed: float
var existing_time: float
var stun_time: float
var maker: Marker2D = null
var from: CharacterBody2D = null
var targets: Array[Node] = []

func _ready():
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


func hit(body: CharacterBody2D) -> void:
	maker.hit_counter()
	targets = []
	queue_free()

func _on_exisiting_timer_timeout() -> void:
	queue_free()

func _on_kunai_hit_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and body in targets:
		var total_damage = basic_damage
		body.handle_hit(from, total_damage)
		hit(body)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
