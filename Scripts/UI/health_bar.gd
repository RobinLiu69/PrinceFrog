extends ProgressBar

@export var player : CharacterBody2D


func _ready():
	player.health_changed.connect(update)
	update()


func update():
	value = player.current_health * 100 / player.max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
