extends CharacterBody2D



@onready var timer: Timer = $Timer 
var source: CharacterBody2D = null
var basic_damage: int
var speed: float
var existing_time: float = -1
var maker: Marker2D = null
var targets: Array[Node] = []
var revolution_radius: float
var rotation_speed: float 

func _ready():
	pass

func _process(delta):
	move_and_slide()

func hit(body: CharacterBody2D) -> void:
	maker.hit_counter()


func _on_leaf_hit_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and body != source:
		var total_damage = basic_damage
		body.handle_hit(source, total_damage)
		hit(body)
