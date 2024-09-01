extends Node

var main_menu: PackedScene = preload("res://resources/scenes/mainmenu.tscn")

func _ready():
	Console.pause_enabled = true
	Console.add_command("teleport", teleport, ["x", "y"], 2)
	Console.add_command("kill", kill)
	Console.add_command("up", up, ["amount"])
	Console.add_command("reset", reset)
	Console.add_command("menu", menu)

func teleport(x, y):
	x = int(x)
	y = int(y)
	World.instance.local_player.position = Vector2(x, y)

func kill():
	World.instance.local_player.kill()

func up(amount):
	amount = int(amount)
	World.instance.local_player.position.y -= amount

func reset():
	World.instance.on_retry()

func menu():
	get_tree().change_scene_to_packed(main_menu)
