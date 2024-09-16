extends Node2D

@export_enum("active", "passive", "blank", "value storage") var grid_type: String
@export var grid_position: Vector2

@export_category("Active and Passive")
@export var weapon_scene: PackedScene
var weapon: Node = null

@export_category("Value Storage")
@export_group("Health")
@export var max_health_bonus: int = 0
@export_group("Movement Speed")
@export var move_speed_bonus: int = 0
@export var move_speed_percent_bonus: int = 0


@export_group("Damage")
@export_subgroup("Base Damage")
@export var base_damage_bonus: int = 0
@export var base_damage_percent_bonus: int = 0
@export_subgroup("Crit Damage")
@export var crit_damage_bonus: int = 0
@export var crit_chance_bonus: int = 0
@export_subgroup("Element Special")
@export var grass_lifesteal_rate: int = 0


@export_group("Defence")
@export var physical_defence_bonus: int = 0
@export var elements_resistance_bonus: int = 0
@export var grass_defence_bonus: int = 0
@export var fire_defence_bonus: int = 0
@export var water_defence_bonus: int = 0
@export var poison_defence_bonus: int = 0
@export var electric_defence_bonus: int = 0


func _ready() -> void:
	if weapon_scene:
		weapon = weapon_scene.instantiate()
		add_child(weapon)
