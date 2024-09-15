extends Node2D

@export var grid_position: Vector2
@export var weapon_scene: PackedScene
var weapon: Node = null
var grid_type: String = "active"

func _ready() -> void:
	if weapon_scene:
		weapon = weapon_scene.instantiate()
		add_child(weapon)
