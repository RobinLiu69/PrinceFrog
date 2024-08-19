extends CharacterBody2D

@export var basic_damage: int = 20
@onready var speed: float = 200.0
@onready var anim: AnimationPlayer = $AnimationPlayer
@export var from: CharacterBody2D = null
@export var target: int = 0


func _ready():
	anim.play("attack")
	pass

func _process(delta):
	
	movement(delta)
	move_and_slide()
	
	
	
func movement(delta: float) -> bool:
	if target:
		velocity = (Vector2.RIGHT * speed).rotated(rotation) * 2.5
		print("stone: ", position)
		return true
	return false



func _on_visible_on_screen_enabler_2d_screen_exited():
	print("out")
	queue_free()

func hit():
	target = false
	velocity = Vector2.ZERO
	anim.play("break", -1., 3)
	
	await anim.animation_finished
	print("out")
	queue_free()



func _on_stone_body_entered(body):
	if body.has_method("handle_hit") and body != from:
		var total_damage = basic_damage
		body.handle_hit(from, total_damage)
		hit()
		
		
 
