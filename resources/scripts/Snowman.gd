extends Area2D
class_name Snowman

static var SNOWMAN_KILLS = 0

var tile_cords: Vector2i

func _on_area_entered(area: Area2D):
	if area is Lava:
		queue_free()
		return
	if not area.get_parent() is Player:
		return
	SNOWMAN_KILLS += 1
	World.instance.set_cell(tile_cords.x, tile_cords.y, 4, 7)
	queue_free()
	
