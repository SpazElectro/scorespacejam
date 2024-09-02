extends Control
class_name MainMenu

var main_scene: PackedScene = preload("res://resources/scenes/main.tscn")

var music_player: AudioStreamPlayer

static var instance: MainMenu

func _ready():
	instance = self
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	music_player = get_node("MusicPlayer")
	if not get_parent().has_node("MusicPlayer"):
		music_player.reparent.call_deferred(get_parent())
		music_player.play()
	else:
		music_player.queue_free()
		music_player = get_parent().get_node("MusicPlayer")
	
	$Main/FreakyMode.visible = Shared.freaky_mode
	Shared._gamemode = Shared.GAMEMODE.ENDLESS

func _on_play_pressed():
	$AnimationPlayer.play("open_gamemodes")
func _on_options_pressed():
	$AnimationPlayer.play("open_options")
func _on_exit_pressed():
	get_tree().quit()

func _on_game_name_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Main/FreakyMode.visible = not $Main/FreakyMode.visible
			$Options/FreakyWarning.visible = true
			Shared.freaky_mode = $Main/FreakyMode.visible
			Shared.did_freaky_mode = true
			
			if Shared.freaky_mode:
				Console.enable()
			else:
				Console.disable()

func _on_back_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("close_options")
func _on_back_pressed2():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("close_gamemodes")

func _on_gamemode_normal_pressed():
	Shared._gamemode = Shared.GAMEMODE.NORMAL
	get_tree().change_scene_to_packed(main_scene)
func _on_gamemode_endless_pressed():
	Shared._gamemode = Shared.GAMEMODE.ENDLESS
	get_tree().change_scene_to_packed(main_scene)
