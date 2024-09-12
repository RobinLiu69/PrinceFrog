extends Node


func display_number(value: int, position: Vector2, element_type: String = "null", is_critical: bool = false) -> void:
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	
	var color: Color = "#FFFFFF"
	match element_type:
		"grass":
			color = "#4FBF40"
		"fire":
			color = "#FF7700"
		"water":
			color = "#00B2FF"
		"poison":
			color = "#BB00FF"
		"electric":
			color = "#FBFF00"
		_:
			if is_critical:
				color = "#FF0000"
	if value == 0:
		color = "#808080"
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 18 * 2.5
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 1 * 2.5
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 50 * randf(), 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:x", number.position.x + 50 * randf_range(-1, 1), 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()
