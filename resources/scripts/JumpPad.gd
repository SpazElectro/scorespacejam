extends StaticBody2D

# TODO add ability to kill snowmen
func _ready():
	$AudioStreamPlayer2D.volume_db = Shared.get_aud_vol()
	$Area2D.connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("default")

func _on_area_entered(area: Area2D):
	if area is Lava:
		queue_free()
		return
	if not area.get_parent() is Player:
		return
	if area.get_parent().health <= 0:
		return
	if area.get_parent().jump_pad_jumps >= 3:
		return
	
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.7, 1.0)
	$AudioStreamPlayer2D.play()
	area.get_parent().jump_pad_jumps += 1
	$AnimatedSprite2D.play("bounce")
	area.get_parent().velocity.y -= 100000*get_physics_process_delta_time()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")
