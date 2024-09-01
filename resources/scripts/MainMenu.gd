extends Control

var main_scene: PackedScene = preload("res://resources/scenes/main.tscn")

func _ready():
	$Options/Audio.value = Shared.get_real_aud_vol()
	$Options/Music.value = Shared.get_real_mus_vol()

func _on_play_pressed():
	$AnimationPlayer.play("open_gamemodes")
func _on_options_pressed():
	$AnimationPlayer.play("open_options")
func _on_exit_pressed():
	get_tree().quit()

func _on_game_name_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print("pressed on title")
			# TODO easter egg
			

func _on_back_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("close_options")
func _on_audio_drag_ended(_value_changed):
	Shared.set_aud_vol($Options/Audio.value)
func _on_music_drag_ended(_value_changed):
	Shared.set_mus_vol($Options/Music.value)

func _on_gamemode_normal_pressed():
	Shared._gamemode = Shared.GAMEMODE.NORMAL
	get_tree().change_scene_to_packed(main_scene)
func _on_gamemode_endless_pressed():
	Shared._gamemode = Shared.GAMEMODE.ENDLESS
	get_tree().change_scene_to_packed(main_scene)
