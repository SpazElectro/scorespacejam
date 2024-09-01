extends Area2D

func _ready():
	await get_tree().create_timer(randf()).timeout
	$AnimatedSprite2D.play("default")

func play_sound():
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.7, 1.0)
	$AudioStreamPlayer2D.play()
