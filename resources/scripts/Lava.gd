extends Area2D
class_name Lava

@export var base_speed = 50.0
@export var speed_multiplier = 1.0
@export var slow_down_distance = 800.0
@export var offset_above_player = 100.0
static var is_in_space = false
var has_hit = false
var gradual_space_increase = 0

func _ready():
	is_in_space = false
	show()

func _process(delta):
	var player_y = World.instance.local_player.position.y
	var lava_y = position.y
	
	if is_in_space:
		if abs(lava_y-player_y) >= 900 and abs(gradual_space_increase) >= 100:
			World.instance.fade_to_thank_you()
		position.y = lerp(position.y, player_y+100-gradual_space_increase, 0.5)
		gradual_space_increase += -(delta*40) if has_hit else delta*10
		return
	if player_y > lava_y:
		position.y = player_y + offset_above_player
		return
	
	var distance_to_player = abs(player_y - lava_y)
	var adjusted_multiplier = speed_multiplier
	if distance_to_player < slow_down_distance:
		adjusted_multiplier /= 2
	else:
		adjusted_multiplier *= 4
	
	var adjusted_speed = base_speed * (
		1 + (adjusted_multiplier)
	)
	
	position.y -= adjusted_speed * delta

func _on_area_entered(area):
	if area.get_parent() is Player:
		if not is_in_space:
			area.get_parent().kill()
		else:
			has_hit = true
