extends Node

const BASIC_ARRAY: Array[String] = ["physical_defence", "elements_defence", "elements_defence"]



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass



func damage(attacker: CharacterBody2D, victim: CharacterBody2D, physical_damage: float = 0.0, grass_damage: float = 0.0\
, fire_damage: float = 0.0, water_damage: float = 0.0, poison_damage: float = 0.0, electric_damage: float = 0.0) -> bool:
	if is_instance_valid(victim) and is_instance_valid(attacker):
		if BASIC_ARRAY.filter(func(attr): return attr not in victim):
			var value = physical_damage * (1-(victim.armor_class/(victim.armor_class+100)))
			var value = physical_damage * (1-(victim.armor_class/(victim.armor_class+100)))
			

	return true
