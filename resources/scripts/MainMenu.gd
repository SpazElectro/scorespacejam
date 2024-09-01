extends Control
class_name MainMenu

var main_scene: PackedScene = preload("res://resources/scenes/main.tscn")

var music_player: AudioStreamPlayer

static var instance

func _ready():
	instance = self
	
	$Options/Audio.value = Shared.get_real_aud_vol()
	$Options/Music.value = Shared.get_real_mus_vol()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	music_player = get_node("MusicPlayer")
	if not get_parent().has_node("MusicPlayer"):
		music_player.reparent.call_deferred(get_parent())
		music_player.play()
	else:
		music_player.queue_free()
		music_player = get_parent().get_node("MusicPlayer")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	Shared.update_music()
	var tween = get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, 3.0)
	tween.play()
	await tween.finished
	

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
	music_player.volume_db = Shared.get_mus_vol()

func _on_gamemode_normal_pressed():
	Shared._gamemode = Shared.GAMEMODE.NORMAL
	get_tree().change_scene_to_packed(main_scene)
func _on_gamemode_endless_pressed():
	Shared._gamemode = Shared.GAMEMODE.ENDLESS
	get_tree().change_scene_to_packed(main_scene)
