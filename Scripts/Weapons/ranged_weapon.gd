@tool
extends Marker2D 

@export_category("Projectile")
@export_group("Basic Setting")
## If enter a nagative number , it will become INF.
@export var cooldown: float
## Projectile speed, if Satellite is on, than this speed become revolution speed.
@export var speed: float
## A projectile scene, it should have the standard projectile variables. Otherwise, it will trigger an error.
@export var projectile_scene: PackedScene
## If turned on, when calling attack method the projectile will spawn. Otherwise, it will spawn in certain conditions.(See in Trigger)
@export var auto_spawn: bool = false
## The time projectile will last for. When reached the time it will called the projectile's "_on_exisiting_timer_timeout". If enter a nagative number , it will become INF.
@export var existing_time: float = -1
@export_subgroup("Attack")
@export_enum("aggressive", "friendly", "neutral", "all", "not in my group") var target_type: String
@export_enum("nearest", "farthest", "random", "all") var attack_type: String
## If enter a negative number , it will become heal.
@export var base_damage: int
## Attacks deal a percentage of the source's physical damage.
@export_range(0, 100, 1) var physical_damage: int = 0
@export_group("Advance Setting")
## This will make the projectiles spawn at the root scene, this means it will not move with the source.
@export var spawn_at_root_scene: bool = false
## This will make the projectiles facing the target by turning marker rotation and copy it to the projectile rotaion. If there are multiple targets , will facing the closest target.
@export var facing_the_target_rotation: bool = false
@export_enum("source", "marker") var defult_position: String = "marker"


@export_category("Trigger") 
@export var trigger_active: bool = false
@export_group("If", "trigger")
## The "hit count" will add one when the projectile hit targets. And trigger when hit count reach it.
@export var trigger_hit_count: int
@export_group("Then do", "trigger")
## "add_projectile" required "obj max count" be set(can't be zero), or it will not spawn anything.
@export_enum("add_projectile") var trigger_func_name: String = "add_projectile"


@export_category("Special")
## This is a universal radius, meaning that different projectiles have their own radius meanings. All radii are based on source size.
@export var radius: float
@export_group("Area", "area")
@export var area_active: bool = false
## Area radius is based on the source size. etc 150% (1.5), 50% (0.5) of thw source size.
@export var area_radius: float
@export_group("Multiple Projectiles")
@export var multiple_projectiles_active: bool = false
@export var projectiles_amount: int
@export_enum("angle between", "maximum angle") var angle_type: String
## It is for the angle between two projectiles(Degree).
@export var original_shooting_angle: float
@export_group("Satellite")
@export var satellite_active: bool = false
## If enter a nagative number, will trigger an error.
@export var obj_start_count: int
##  If "obj max count smaller" than "obj start count", will trigger an error.
@export var obj_max_count: int
## Rvolution radius is based on the source size. etc 150% (1.5), 50% (0.5) of thw source size.
@export var revolution_radius: float
@export var rotation_speed: float

@export_category("Ability")
@export_group("Stun", "stun")
@export var stun_active: bool = false
## If enter a nagative number, it will become INF.
@export var stun_time: float
@export_group("Slow", "slowness")
@export var slowness_active: bool = false
@export_range(0, 100, 1) var slowness_level: int
## If enter a nagative number, it will become INF.
@export var slowness_time: float

@onready var cooldown_timer: Timer = Timer.new()

const SIZE_CORRECTION: float = 1.75

var obj_list: Array[Node] = []
var obj_count: int = 0
var in_cooldown: bool = false
var hit_count: int = 0
var shooting_angle: float = 0.0

func _ready() -> void:
	assert(projectile_scene, " Not a valid projectile scene")
	var test_projectile: CharacterBody2D = projectile_scene.instantiate()
	assert("source" in test_projectile, test_projectile.name+" don't have the required variable <source>")
	assert("maker" in test_projectile, test_projectile.name+" don't have the required variable <maker>")
	assert("physical_damage" in test_projectile, test_projectile.name+" don't have the required variable <physical_damage>")
	assert("base_damage" in test_projectile, test_projectile.name+" don't have the required variable <base_damage>")
	assert("speed" in test_projectile, test_projectile.name+" don't have the required variable <speed>")
	assert("targets" in test_projectile, test_projectile.name+" don't have the required variable <targets>")
	assert("existing_time" in test_projectile, test_projectile.name+" don't have the required variable <existing_time>")
	assert(not stun_active or ("stun_time" in test_projectile), test_projectile.name+" don't have the stun method under it")
	assert(not slowness_active or ("slowness_level" in test_projectile and "slowness_time" in test_projectile), test_projectile.name+" don't have the slow method under it")
	assert(obj_start_count >= 0, " Can't set obj start count to a nagative number.")
	assert(obj_max_count >= obj_start_count, " Can't have obj start count bigger than obj max count.")
	#assert(not (attack_type == "all" and facing_the_target_rotation == true), " Can't facing mutiple targets.")
	test_projectile.queue_free()
	
	add_child(cooldown_timer)
	cooldown_timer.name = "CooldownTimer"
	cooldown_timer.one_shot = true
	
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	radius *= SIZE_CORRECTION
	if satellite_active:
		for i in range(obj_start_count):
			add_projectile()

	
func attack(source: CharacterBody2D, damage_info: Array = [0]) -> float:
	owner = source
	if not in_cooldown and projectile_scene and auto_spawn:
		in_cooldown = true
		if cooldown > 0:
			cooldown_timer.set_wait_time(cooldown)
			cooldown_timer.start()
		if multiple_projectiles_active and projectiles_amount > 1:
			if angle_type == "maximum angle":
				shooting_angle = original_shooting_angle/(projectiles_amount-1)
			elif angle_type == "angle between":
				shooting_angle = original_shooting_angle
			for i in range(projectiles_amount):
				adjust_projectiles_angle(spawn_projectile(source), i)
		else:
			spawn_projectile(source)
	return false

func get_cooldown_ratio() -> float:
	return snapped(cooldown_timer.get_wait_time()/cooldown, 2)


func reduce_cooldown(percentage: int, amount: int = 0) -> float:
	return snapped(cooldown_timer.get_wait_time()/cooldown, 2)

func adjust_projectiles_angle(projectile: CharacterBody2D, i: int) -> void:
	var j: int = 1 if i%2 == 0 else -1
	if projectiles_amount%2 == 1:
		projectile.rotation_degrees += (shooting_angle*floor((i+1)/2)*j)
	else:
		projectile.rotation_degrees += (shooting_angle*floor((i)/2)*j) + shooting_angle/2 * j

func satellite_movment(delta: float) -> void:
	for i in range(len(obj_list)):
		var obj = obj_list[i]
		var orbit_angle = TAU * (i/float(obj_count))
		obj.position = Vector2(cos(orbit_angle), sin(orbit_angle)) * (revolution_radius * owner.size)
		obj.rotation += rotation_speed * delta * randf()
	rotation += owner.speed/100 * speed * delta if owner else 0

func add_projectile() -> void:
	if obj_count < obj_max_count:
		var obj = spawn_projectile(owner)
		obj_list.append(obj)

func spawn_projectile(source: CharacterBody2D, set_position: Vector2 = Vector2()) -> CharacterBody2D:
	var instance: CharacterBody2D = projectile_scene.instantiate()
	var target_list: Array[Node] = AttackFunc.get_target_list(source, target_type)
	var targets: Array[Node] = [null]
	match attack_type:
		"nearest":
			targets = AttackFunc.find_the_nearest_targets(source, target_list)
		"farthest":
			targets = [AttackFunc.find_the_farthest_targets(source, target_list)]
		"random":
			targets = [AttackFunc.find_random_targets(target_list)]
		"all":
			targets = target_list
	instance.source = source
	instance.base_damage = base_damage
	instance.physical_damage = source.damage * physical_damage/100
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
		else:
			look_at(AttackFunc.find_the_nearest_targets(source, target_list)[0].global_position)
			instance.rotation = rotation
	if area_active:
		instance.area_radius = area_radius
	if satellite_active:
		instance.revolution_radius = revolution_radius
		instance.rotation_speed = rotation_speed
	if stun_active:
		instance.stun_time = stun_time
	if slowness_active:
		instance.slowness_time = slowness_time
		instance.slowness_level = slowness_level
	if defult_position == "marker" and set_position == Vector2.ZERO:
		instance.global_position = global_position
	elif defult_position == "onwer" and set_position == Vector2.ZERO:
		instance.global_position = source.global_position
	elif set_position != Vector2.ZERO:
		instance.global_position = set_position
	obj_count += 1
	return instance

func hit_counter() -> void:
	hit_count += 1
	if hit_count == trigger_hit_count:
		call(trigger_func_name)
		hit_count = 0

func _process(delta: float) -> void:
	if satellite_active:
		satellite_movment(delta)


func _on_cooldown_timer_timeout() -> void:
	in_cooldown = false
