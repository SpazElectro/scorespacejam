extends Area2D
class_name Coin

func _ready():
	$AudioStreamPlayer2D.volume_db = Shared.get_aud_vol()
	await get_tree().create_timer(randf()).timeout
	$AnimatedSprite2D.play("default")

func play_sound():
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.7, 1.0)
	$AudioStreamPlayer2D.play()
