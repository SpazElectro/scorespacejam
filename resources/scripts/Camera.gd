extends Camera2D
class_name Camera

@export var shake_intensity = 10.0
@export var shake_frequency = 5.0
@export var shake_duration = 0.5

var shake_timer = 0.0
var shake_offset = Vector2()

static var instance: Camera

func _ready():
	instance = self

func _process(delta):
	position.x = 256
	position.y = World.instance.local_player.position.y
	
	if shake_timer > 0:
		shake_timer -= delta
		shake_offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		position += shake_offset
		shake_timer = max(shake_timer, 0)
	else:
		shake_offset = Vector2()

static func shake_camera(intensity: float, duration: float):
	instance.shake_intensity = intensity
	instance.shake_duration = duration
	instance.shake_timer = duration
