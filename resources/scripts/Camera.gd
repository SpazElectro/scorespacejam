extends Camera2D

@export var addt = 0.0
@export var base_frequency = 1.0
@export var max_frequency = 5.0
@export var lerp_speed = 2.0
@export var speed_divider = 1.0

var frames = 0.0
var current_frequency = base_frequency

func _process(delta):
	var player_speed = World.instance.local_player.current_speed/speed_divider
	var target_frequency = base_frequency + (player_speed / World.instance.local_player.speed) * (max_frequency - base_frequency)
	
	current_frequency = lerp(current_frequency, target_frequency, lerp_speed * delta)
	frames += delta * current_frequency
	
	var s = 1.0 + abs(sin(frames * PI * 2)) * 0.1 + addt
	
	zoom = Vector2(s, s)
	position.y = World.instance.local_player.position.y
