extends Node

func _ready():
	Console.pause_enabled = true
	Console.add_command("teleport", teleport, ["x", "y"], 2)
	Console.add_command("kill", kill)
	Console.add_command("up", up, ["amount"])
	Console.add_command("reset", reset)

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
