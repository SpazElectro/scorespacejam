extends Area2D
class_name Lava

@export var base_speed = 50.0
@export var speed_multiplier = 1.0
@export var slow_down_distance = 800.0

func _ready():
	show()

func _process(delta):
	var player_y = World.instance.local_player.position.y
	var lava_y = position.y
	
	var distance_to_player = abs(player_y - lava_y)
	
	var adjusted_multiplier = speed_multiplier
	if distance_to_player < slow_down_distance:
		adjusted_multiplier *= distance_to_player / slow_down_distance
	
	var adjusted_speed = base_speed * (1 + (adjusted_multiplier * (1.0 - player_y / get_viewport_rect().size.y)))
	
	position.y -= adjusted_speed * delta

func _on_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent().kill()
