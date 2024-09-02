extends Node

var main_menu: PackedScene = preload("res://resources/scenes/main_menu.tscn")

func _ready():
	Console.pause_enabled = true
	Console.disable()
	Console.add_command("teleport", teleport, ["x", "y"], 2)
	Console.add_command("kill", kill)
	Console.add_command("up", up, ["amount"], 1)
	Console.add_command("reset", reset)
	Console.add_command("menu", menu)
	Console.add_command("music", music)
	Console.add_command("audio", audio)
	Console.add_command("nextsong", nextsong)
	Console.add_command("lava", lava, ["speed"])
	Console.add_command("player", player)

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

func music():
	if Shared.get_real_mus_vol() != 0:
		Shared.set_mus_vol(0)
	else:
		Shared.set_mus_vol(100)
func audio():
	if Shared.get_real_aud_vol() != 0:
		Shared.set_aud_vol(0)
	else:
		Shared.set_aud_vol(100)

func nextsong():
	var m: AudioStreamPlayer = get_tree().root.get_node("MusicPlayer")
	m.play(m.stream.get_length())

func lava(x):
	Console.print_line("The lava is at %d" % [World.instance.get_node("Lava").position.y])
	x = int(x)
	if x:
		World.instance.get_node("Lava").base_speed = x

func player():
	Console.print_line("The player is at %d" % [World.instance.local_player.position.y])
