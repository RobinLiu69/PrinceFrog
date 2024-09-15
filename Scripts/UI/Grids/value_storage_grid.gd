extends Node2D

@export var grid_position: Vector2

@export_category("Health")
@export var max_health_bonus: int = 0
@export_category("Movement Speed")
@export var move_speed_bonus: int = 0
@export var move_speed_percent_bonus: int = 0


@export_category("Damage")
@export_group("Base Damage")
@export var base_damage_bonus: int = 0
@export var base_damage_percent_bonus: int = 0
@export_group("Crit Damage")
@export var crit_damage_bonus: int = 0
@export var crit_chance_bonus: int = 0
@export_group("Element Special")
@export var grass_lifesteal_rate: int = 0


@export_category("Defence")
@export var physical_defence_bonus: int = 0
@export var elements_resistance_bonus: int = 0
@export var grass_defence_bonus: int = 0
@export var fire_defence_bonus: int = 0
@export var water_defence_bonus: int = 0
@export var poison_defence_bonus: int = 0
@export var electric_defence_bonus: int = 0

var grid_type: String = "value storage"
