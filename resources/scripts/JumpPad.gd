extends StaticBody2D

# TODO add ability to kill snowmen
func _ready():
	$Area2D.connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("default")

func _on_area_entered(area: Area2D):
	if area is Lava:
		queue_free()
		return
	if not area.get_parent() is Player:
		return
	if not area.get_parent().alive:
		return
	if area.get_parent().jump_pad_jumps >= (3 if Shared.cheats_enabled else 2):
		return
	
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.7, 1.0)
	$AudioStreamPlayer2D.play()
	area.get_parent().jump_pad_jumps += 1
	$AnimatedSprite2D.play("bounce")
	area.get_parent().velocity.y -= (100_000 if Shared.cheats_enabled else 80_000)*get_physics_process_delta_time()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")
