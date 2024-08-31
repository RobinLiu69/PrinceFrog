@tool
extends Marker2D 

@export_category("Projectile")
@export_group("Basic")
@export var basic_damage: int
@export var cooldown: float
@export var speed: float # if Satellite is on, than this speed is revolution speed
@export var projectile: PackedScene
@export var auto_spawn: bool = false
@export var existing_time: float = INF
@export_group("Advance")
@export var spawn_at_root_scene: bool = false
@export var copy_marker_rotation: bool = false
@export var copy_marker_position: bool = false


@export_category("Trigger") # in method trigger their is a trigger to trigger things
@export var trigger: bool = false
@export_group("If")
@export var hit_count: int
@export_group("Then do")
@export_enum("add_projectile") var func_name: String


@export_category("Special")
@export_group("Area")
@export var area: bool = false
@export var area_radius: float
@export_group("Satellite")
@export var satellite: bool = false
@export var satellite_start_count: int
@export var satellite_max_count: int
@export var revolution_radius: float
@export var rotation_speed: float

@export_category("Ability")
@export_group("Stun")
@export var stun: bool = false
@export var stun_time: float
@export_group("Slow")
@export var slow: bool = false
@export var slow_level: float
@export var slow_time: float


@onready var enemy_list: Array[Node] = get_tree().get_nodes_in_group("enemy")
@onready var allay_list: Array[Node] = get_tree().get_nodes_in_group("allay")
@onready var timer: Timer = $Timer

var in_cooldown: bool = false




func _ready():
	pass


func find_nearst_target(target_list: Array[Node]) -> CharacterBody2D:
	var nearst_target: CharacterBody2D = null
	var distance: float = INF
	
	for target in target_list:
		if global_position.distance_squared_to(target.global_position) < distance:
			nearst_target = target
			distance = global_position.distance_squared_to(target.global_position)
	
	return nearst_target if is_instance_valid(nearst_target) else null

func target_type() -> Array[Node]:
	if get_parent().get_parent() in enemy_list: return allay_list
	elif get_parent().get_parent() in allay_list: return enemy_list 
	return [null]	
	
func attack(from: CharacterBody2D, damage_info: Array = [0]) -> bool:
	if not in_cooldown:
		in_cooldown = true
		timer.set_wait_time(cooldown)
		timer.start()
		
		var projectile_instance = projectile.instantiate()
		
		var nearst_target = find_nearst_target(target_type())
		
		spawn_projectile(from, projectile_instance, nearst_target)
	return false



func spawn_projectile(from: CharacterBody2D, instance: CharacterBody2D, nearst_enemy: CharacterBody2D, defult_position: Vector2 = Vector2()) -> bool:
	if nearst_enemy:
		look_at(nearst_enemy.global_position)
		instance.from = from
		instance.basic_damage = basic_damage
		instance.speed = speed
		instance.target = nearst_enemy
		if stun:
			print(stun_time)
			instance.stun_time = stun_time
		if slow:
			instance.slow_time = slow_time
			instance.slow_level = slow_level
		if copy_marker_rotation:
			instance.rotation = rotation
		if spawn_at_root_scene:
			get_tree().current_scene.add_child(instance)
		else:
			add_child(instance)
		if copy_marker_position and defult_position == Vector2.ZERO:
			instance.global_position = global_position
		elif defult_position != Vector2.ZERO:
			instance.global_position = defult_position
		return true
	return false

func _process(delta):
	enemy_list = get_tree().get_nodes_in_group("enemy")
	allay_list = get_tree().get_nodes_in_group("allay")


func _on_timer_timeout() -> void:
	in_cooldown = false
