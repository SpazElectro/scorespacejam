extends Area2D

@export var speed = 20.0

func _ready():
	show()

func _process(delta):
	position.y -= speed*delta

func _on_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent().kill()
