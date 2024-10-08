@tool
extends CharacterBody2D 

@export_category("Weapon")
@export_group("Basic Setting")
## If enter a nagative number is will bercome INF.
@export var cooldown: float
## Animation speed.
@export var anim_speed: float
## If turned on. When calling attack method and excute the action. Otherwise, it will attack in certain conditions.(See in Trigger)
@export var auto_attack: bool = false
@export_subgroup("Attack")
@export_enum("aggressive", "friendly", "neutral", "all", "not in my group") var target_type: String
@export_enum("nearest", "farthest", "random", "all") var attack_type: String
## If enter a nagative number is will bercome heal.
@export var base_damage: int
## Attacks deal a percentage of the owner's physical damage.
@export_range(0, 1, 0.01) var physical_damage: float = 0
@export_group("Advance Setting")
@export var facing_the_target_rotation: bool = false
## If enter a nagative number, will trigger an error.
@export var obj_start_count: int
##  If "obj max count smaller" than "obj start count", will trigger an error.
@export var obj_max_count: int


@export_category("Trigger") 
@export var trigger_active: bool = false
@export_group("If", "trigger")
## The "hit count" will add one when the projectile hit targets. And trigger when hit count reach it.
@export var trigger_hit_count: int
@export_group("Then do", "trigger")
## "add_projectile" required "obj max count" be set(can't be zero), or it will not spawn anything.
@export_enum("add_projectile") var trigger_func_name: String = "add_projectile"


@export_category("Special")
## This is a universal radius, meaning that different projectiles have their own radius meanings. All radii are based on owner size.
@export var radius: float
@export_group("Area", "area")
@export var area_active: bool = false
## Area radius is based on the owner size. etc 150% (1.5), 50% (0.5) of thw owner size.
@export var area_radius: float

@export_category("Ability")
@export_group("Stun", "stun")
@export var stun_active: bool = false
## If enter a nagative number, it will bercome INF.
@export var stun_time: float
@export_group("Slow", "slow")
@export var slow_active: bool = false
@export_range(0, 1, 0.01) var slow_level: float
## If enter a nagative number, it will bercome INF.
@export var slow_time: float

@onready var timer: Timer = $Timer

const group_names: Array[String] = ["aggressive", "friendly", "neutral"]
const size_correction: float = 1.75

var obj_list: Array[Node] = []
var obj_count: int = 0
var in_cooldown: bool = false
var hit_count: int = 0



func _ready() -> void:
	assert(obj_start_count >= 0, " Can't set obj start count to a nagative number.")
	assert(obj_max_count >= obj_start_count, " Can't have obj start count bigger than obj max count.")
	assert(attack_type != "all" and facing_the_target_rotation == true, " Can't facing mutiple targets.")
	radius *= size_correction


func find_the_nearest_target(target_list: Array[Node]) -> CharacterBody2D:
	var nearest_target: CharacterBody2D = null
	var distance: float = INF
	
	for target in target_list:
		if owner.global_position.distance_squared_to(target.global_position) < distance:
			nearest_target = target
			distance = owner.global_position.distance_squared_to(target.global_position)
	
	return nearest_target if is_instance_valid(nearest_target) else null

func find_the_farthest_target(target_list: Array[Node]) -> CharacterBody2D:
	var farthest_target: CharacterBody2D = target_list.pick_random()
	var distance: float = owner.global_position.distance_squared_to(farthest_target.global_position)
	for target in target_list:
		if owner.global_position.distance_squared_to(target.global_position) > distance:
			farthest_target = target
			distance = owner.global_position.distance_squared_to(target.global_position)
	
	return farthest_target if is_instance_valid(farthest_target) else null

func find_random_target(target_list: Array[Node]) -> CharacterBody2D:
	return target_list.pick_random()

func get_target_list() -> Array[Node]:
	var owner_group_names: Array[StringName] = owner.get_groups()
	var target_list: Array
	match target_type:
		"not in my group":
			for group_name in group_names.filter(func(name): return name not in owner_group_names):
				target_list += get_tree().get_nodes_in_group(group_name)
			return target_list
		_:
			target_list = get_tree().get_nodes_in_group(target_type)
			return target_list
	
func attack(source: CharacterBody2D, damage_info: Array = [0]) -> bool:
	if not in_cooldown and projectile_scene and auto_spawn:
		in_cooldown = true
		if cooldown > 0:
			timer.set_wait_time(cooldown)
			timer.start()
		
		spawn_projectile(source)
	return false

func satellite_movment(delta: float) -> void:
	for i in range(len(obj_list)):
		var obj = obj_list[i]
		var orbit_angle = TAU * (i/float(obj_count))
		obj.position = Vector2(cos(orbit_angle), sin(orbit_angle)) * ((revolution_radius * owner.size) ** 2)
		obj.rotation += rotation_speed * delta * randf()
	rotation += speed * delta

func add_projectile() -> void:
	if obj_count < obj_max_count:
		var obj = spawn_projectile(owner)
		obj_list.append(obj)

func spawn_projectile(source: CharacterBody2D, set_position: Vector2 = Vector2()) -> CharacterBody2D:
	var instance: CharacterBody2D = projectile_scene.instantiate()
	var target_list: Array[Node] = get_target_list()
	var targets: Array[Node] = [null]
	match attack_type:
		"nearest":
			targets = [find_the_nearest_target(target_list)]
		"farthest":
			targets = [find_the_farthest_target(target_list)]
		"random":
			targets = [find_random_target(target_list)]
		"all":
			targets = target_list
	instance.source = source
	instance.base_damage = base_damage
	instance.speed = speed
	instance.targets = targets
	instance.existing_time = existing_time
	instance.maker = self
	if radius:
		instance.radius = radius
	if spawn_at_root_scene:
		get_tree().current_scene.add_child(instance)
	else:
		add_child(instance)
	if facing_the_target_rotation:
		if len(targets) == 1:
			look_at(targets[0].global_position)
			instance.rotation = rotation
	if stun_active:
		instance.stun_time = stun_time
	if slow_active:
		instance.slow_time = slow_time
		instance.slow_level = slow_level
	if defult_position == "marker" and set_position == Vector2.ZERO:
		instance.global_position = global_position
	elif defult_position == "onwer" and set_position == Vector2.ZERO:
		instance.global_position = owner.global_position
	elif set_position != Vector2.ZERO:
		instance.global_position = set_position
	obj_count += 1
	return instance

func hit_counter() -> void:
	hit_count += 1
	if hit_count == trigger_hit_count:
		call(trigger_func_name)

func _process(delta: float) -> void:
	if satellite_active:
		satellite_movment(delta)


func _on_timer_timeout() -> void:
	in_cooldown = false
