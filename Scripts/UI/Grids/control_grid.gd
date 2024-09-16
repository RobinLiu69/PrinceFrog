extends Node2D

@onready var grids: Array[Node] = get_children()
var grids_info: Array = []
var weapons_list: Array = []

var max_health_bonus: int = 0
var move_speed_bonus: int = 0
var move_speed_percent_bonus: int = 0

var base_damage_bonus: int = 0
var base_damage_percent_bonus: int = 0
var crit_damage_bonus: int = 0
var crit_chance_bonus: int = 0
var grass_lifesteal_rate: int = 0

var physical_defence_bonus: int = 0
var elements_resistance_bonus: int = 0
var grass_defence_bonus: int = 0
var fire_defence_bonus: int = 0
var water_defence_bonus: int = 0
var poison_defence_bonus: int = 0
var electric_defence_bonus: int = 0



func _ready() -> void:
	for grid in grids:
		match grid.grid_type:
			"active":
				weapons_list.append(["active", grid.weapon])
			"passive":
				weapons_list.append(["passive", grid.weapon])
			"value storage":
				max_health_bonus += grid.max_health_bonus
				move_speed_bonus += grid.move_speed_bonus
				move_speed_percent_bonus += grid.move_speed_percent_bonus
				
				base_damage_bonus += grid.base_damage_bonus
				base_damage_percent_bonus += grid.base_damage_percent_bonus
				crit_damage_bonus += grid.crit_damage_bonus
				crit_chance_bonus += grid.crit_chance_bonus
				grass_lifesteal_rate += grid.grass_lifesteal_rate
				
				physical_defence_bonus += grid.physical_defence_bonus
				elements_resistance_bonus += grid.elements_resistance_bonus
				grass_defence_bonus += grid.grass_defence_bonus
				fire_defence_bonus += grid.fire_defence_bonus
				water_defence_bonus += grid.water_defence_bonus
				poison_defence_bonus += grid.poison_defence_bonus
				electric_defence_bonus += grid.electric_defence_bonus
			"blank":
				pass
		grids_info.append({"type": grid.grid_type, "position": grid.grid_position, "node": grid})
