extends Control

var in_menu = false

func unpause():
	get_tree().paused = false
	if not in_menu:
		get_parent().hide()
	else: hide()
func pause():
	get_tree().paused = true
	if not in_menu:
		get_parent().show()
	else: show()

func _ready():
	await get_tree().process_frame
	
	var btarget
	if MainMenu.instance != null:
		# inmenu
		in_menu = true
		btarget = MainMenu.instance._on_back_pressed
	else:
		# ingame
		in_menu = false
		btarget = func():
			unpause()
		$MainMenu.visible = true
		if Shared.freaky_mode:
			$Cheats.visible = true
	
	$Audio.connect("drag_ended", _on_audio_drag_ended)
	$Music.connect("drag_ended", _on_music_drag_ended)
	$MainMenu.connect("pressed", _go_to_main_menu)
	$Back.connect("pressed", btarget)
	$Cheats.connect("toggled", _cheats_toggled)
	
	$Audio.value = Shared.get_real_aud_vol()
	$Music.value = Shared.get_real_mus_vol()
	
	#Shared.update_music()

func _input(event):
	if not in_menu:
		if event is InputEventKey:
			if event.pressed:
				if event.keycode == KEY_ESCAPE:
					if get_tree().paused:
						unpause()
					else: pause()

func _on_audio_drag_ended(_value_changed):
	Shared.set_aud_vol($Audio.value)
func _on_music_drag_ended(_value_changed):
	Shared.set_mus_vol($Music.value)
	get_tree().root.get_node("MusicPlayer").volume_db = Shared.get_mus_vol()

func _go_to_main_menu():
	unpause()
	get_tree().change_scene_to_packed(Commands.main_menu)
func _cheats_toggled(new: bool):
	Shared.cheats_enabled = new
	if new:
		World.instance.local_player.speed = 800
		World.instance.local_player.shoot_timer = 0
		World.instance.local_player.recoil = 200
		World.instance.local_player.walljump_force = 40_000
		World.instance.local_player.dash_power = 45_000
		World.instance.local_player.max_jumps = 500
		World.instance.local_player.max_dashes = 500
		World.instance.local_player.max_speed = 10_000
	else:
		World.instance.local_player.speed = 500
		World.instance.local_player.shoot_timer = 0
		World.instance.local_player.recoil = 80
		World.instance.local_player.walljump_force = 20_000
		World.instance.local_player.dash_power = 30_000
		World.instance.local_player.max_jumps = 3
		World.instance.local_player.max_dashes = 3
		World.instance.local_player.max_speed = 2_000
	
