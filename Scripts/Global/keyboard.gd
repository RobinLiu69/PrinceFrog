extends Node
func _ready() -> void:
	var grid = []

	grid.append([])
	for i in range(12):
		grid[0].append(0) # 这里的0是一个占位符，你可以放置任何你需要的值
	grid.append([])
	for i in range(12):
		grid[1].append(0)
	grid.append([])
	for i in range(11):
		grid[2].append(0)
	grid.append([])
	for i in range(10):
		grid[3].append(0)
