extends Node


func display_number(value: int, position: Vector2, element_type: String = "null", is_critical: bool = false) -> void:
	var container = HBoxContainer.new()
	container.global_position = position
	container.z_index = 10
	
	# 创建并加载图标
	if element_type != "null":
		var icon = TextureRect.new()
		var texture_path = ""
		match element_type:
			"grass":
				texture_path = "res://Images/Effects/elements/grass.png"
			"fire":
				texture_path = "res://Images/Effects/elements/fire.png"
			"water":
				texture_path = "res://Images/Effects/elements/water.png"
			"poison":
				texture_path = "res://Images/Effects/elements/poison.png"
			"electric":
				texture_path = "res://Images/Effects/elements/electric.png"
		icon.texture = load(texture_path)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		#icon.scale = Vector2(20, 20)  # 调整图标大小
		container.add_child(icon)

	# 创建数字标签
	var number = Label.new()
	number.text = str(value)
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
	
	container.add_child(number)
	call_deferred("add_child", container)
	
	await number.resized
	#container.pivot_offset = Vector2(container.size)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		container, "position:y", container.position.y - 50 * randf(), 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		container, "position:x", container.position.x + 50 * randf_range(-1, 1), 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		container, "position:y", container.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		container, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	container.queue_free()
