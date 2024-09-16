extends Node

var inventory: Array = []
var item_list: Dictionary = {}
@export var item_scene: PackedScene

var keyboard: Array = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "Minus", "Equal"],
						["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "BracketLeft", "BracketRight", "BackSlash"],
						["A", "S", "D", "F", "G", "H", "J", "K", "L", "Semicolon", "Apostrophe"],
						["Z", "X", "C", "V", "B", "N", "M", "Comma", "Period", "Slash"],
						["space"]]
var keyboard_bind:  Dictionary


func _ready() -> void:
	inventory = init_inventory(4, [12, 12, 11, 10])
	var item = null
	if item_scene:
		item = item_scene.instantiate()
	equip(item, 3, 2)
	print(inventory)
	inventory_update()
	
	await get_tree().create_timer(5.0).timeout
	print(unequip(4, 2))
	inventory_update()
	
	
func init_inventory(row_counts: int, slots_in_rows: Array[int]) -> Array:
	var empty_inventory: Array = []
	if row_counts > len(slots_in_rows): for i in range(row_counts-len(slots_in_rows)): slots_in_rows.append(0)
	for i in range(row_counts):
		empty_inventory.append([])
		for j in range(slots_in_rows[i]):
			empty_inventory[i].append(false)
	return empty_inventory

func inventory_update() -> void:
	for i in range(len(inventory)):
		if i + 1 > len(keyboard): continue
		for j in range(len(inventory[i])):
			if j + 1 > len(keyboard[i]): continue
			keyboard_bind[keyboard[i][j]] = inventory[i][j]
			

func equip(item: Node2D, x: int, y: int) -> bool:
	if item:
		add_child(item)
		for grid_info in item.grids_info:
			var item_x = x+grid_info["position"][0]
			var item_y = y+grid_info["position"][1]
			if item_y >= len(inventory) or item_y < 0:
				remove_child(item)
				return false
			if item_x >= len(inventory[item_y]) or item_x < 0:
				remove_child(item)
				return false
			if inventory[item_y][item_x] != false:
				remove_child(item)
				return false
		for grid_info in item.grids_info:
			var item_x = x+grid_info["position"][0]
			var item_y = y+grid_info["position"][1]
			inventory[item_y][item_x] = grid_info["node"]
		item_list[str(x)+"-"+str(y)] = item
		return true
	return false


func unequip(x: int, y: int) -> Node:
	if not inventory[y][x]: return null
	var offset_position: Vector2 = inventory[y][x].grid_position
	var center_position: Vector2 = Vector2(x, y) - offset_position
	var center_equipment: Node = item_list[str(center_position[0])+"-"+str(center_position[1])]
	item_list.erase(str(center_position[0])+"-"+str(center_position[1]))
	for grid_info in center_equipment.grids_info:
		inventory[center_position[1]+grid_info["position"][1]][center_position[0]+grid_info["position"][0]] = false
	return center_equipment

func _process(delta: float) -> void:
	for item in item_list.values():
		for weapon_info in item.weapons_list:
			if weapon_info[0] == "passive": weapon_info[1].attack(owner)

func pressed_key(key: String) -> bool:
	if keyboard_bind.has(key):
		if keyboard_bind[key]:
			if keyboard_bind[key].grid_type == "active":
				keyboard_bind[key].weapon.attack(owner)
				return true
	return false
