extends Node

const BASIC_ARRAY: Array[String] = ["armor_class", "armor_class"]



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass



func damage(attacker: CharacterBody2D, victim: CharacterBody2D, pysical_damage: float = 0.0, grass_damage: float = 0.0\
, fire_damage: float = 0.0, water_damage: float = 0.0, poison_damage: float = 0.0, electric_damage: float = 0.0) -> bool:
	if is_instance_valid(victim) and is_instance_valid(attacker):
		#if victim.has_method("damage"):
			#victim.
		if BASIC_ARRAY.filter(func(attr): return attr not in victim):
			var value = pysical_damage * (1-(victim.armor_class/(victim.armor_class+100)))
			
		
	return true
