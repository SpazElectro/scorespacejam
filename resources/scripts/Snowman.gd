extends Area2D

var tile_cords: Vector2i

func _on_area_entered(area: Area2D):
	if area is Lava:
		queue_free()
		return
	if not area.get_parent() is Player:
		return
	World.instance.set_cell(tile_cords.x, tile_cords.y, 4, 7)
	queue_free()
