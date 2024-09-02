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

#var prev_state = ""
#var state = ""

func _process(delta):
	var player_y = World.instance.local_player.position.y
	var lava_y = position.y
	
	if is_in_space:
		if abs(lava_y - player_y) >= 700 and abs(gradual_space_increase) >= 100:
			World.instance.fade_to_thank_you()
		position.y = lerp(position.y, player_y + 100 - gradual_space_increase, 0.5)
		gradual_space_increase += -(delta * 40) if has_hit else delta * 10
		return
	
	if player_y > lava_y:
		position.y = player_y + offset_above_player
		return
	
	# I am very sorry
	var adjusted_speed = -100 if Shared.is_mobile else 0
	if player_y >= 359:
		adjusted_speed = 10
		#state = "A"
	else:
		var ratio = abs(player_y)/abs(lava_y)
		var distance = abs(player_y-lava_y)
		
		if ratio <= 1.1:
			if distance >= 800:
				adjusted_speed = 1200
				#state = "B"
			else:
				# these 2 are very snappy
				if distance >= 300:
					adjusted_speed = 600
					#state = "C"
				else:
					adjusted_speed = 300
					#state = "D"
		else:
			if distance >= 800:
				adjusted_speed = 1200*(distance/100)
				#state = "E"
			else:
				adjusted_speed = 400
				#state = "F"
	
	if Shared.is_mobile:
		adjusted_speed /= 2
	#if state != prev_state:
		#print("New lava state: %s" % [state])
	
	position.y -= adjusted_speed * delta
	#prev_state = state

func _on_area_entered(area):
	if area.get_parent() is Player:
		if area.get_parent().alive:
			if not is_in_space:
				area.get_parent().kill()
			else:
				has_hit = true
