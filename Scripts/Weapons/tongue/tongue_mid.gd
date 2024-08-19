extends Line2D


func _process(delta):
	global_position = Vector2.ZERO
	global_rotation = 0
	clear_points()
	add_point(get_parent().global_position)
	add_point(get_parent().from.global_position)
