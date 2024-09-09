extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var poop_area_scene: PackedScene = preload("res://Scenes/Weapons/poop/poop_area.tscn")

var basic_damage: int
var speed: float
var slowness_time: float 
var slowness_level: float
var existing_time: float
var source: CharacterBody2D = null
var targets: Array = []
var maker: Marker2D = null

func _ready():
	timer.set_wait_time(existing_time)
	timer.start()

func slow():
	pass
	
func _process(delta):
	move_and_slide()
	
func hit(body: CharacterBody2D) -> void:
	var poop_area: CharacterBody2D = poop_area_scene.instantiate()
	poop_area.source = source
	poop_area.slowness_time = slowness_time
	poop_area.slowness_level = slowness_level
	poop_area.scale = scale
	get_tree().current_scene.add_child(poop_area)
	poop_area.global_position = global_position
	queue_free()

	
func _on_poop_hit_body_entered(body: Node2D) -> void:
	if body.has_method("handle_hit") and body != source:
		hit(body)

func _on_timer_timeout() -> void:
	queue_free()
