extends StaticBody2D

# TODO add ability to kill snowmen
func _ready():
	$Area2D.connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("default")

func _on_area_entered(area: Area2D):
	if not area.get_parent() is Player:
		return
	
	$AnimatedSprite2D.play("bounce")
	area.get_parent().velocity.y -= 100000*get_physics_process_delta_time()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")
