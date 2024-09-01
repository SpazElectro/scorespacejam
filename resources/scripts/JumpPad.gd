extends StaticBody2D

var launch_power = 90_000

# TODO add ability to kill snowmen
func _ready():
	$AudioStreamPlayer2D.volume_db = Shared.get_aud_vol()
	$Area2D.connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("default")
	
	if Shared.freaky_mode:
		launch_power = 100_000

func _on_area_entered(area: Area2D):
	if area is Lava:
		queue_free()
		return
	if not area.get_parent() is Player:
		return
	if area.get_parent().health <= 0:
		return
	if area.get_parent().jump_pad_jumps >= (4 if Shared.freaky_mode else 2):
		return
	
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.7, 1.0)
	$AudioStreamPlayer2D.play()
	area.get_parent().jump_pad_jumps += 1
	$AnimatedSprite2D.play("bounce")
	area.get_parent().velocity.y -= launch_power*get_physics_process_delta_time()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")
