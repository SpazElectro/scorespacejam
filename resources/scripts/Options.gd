extends Control


func _ready():
	var atarget
	var mtarget
	if MainMenu.instance != null:
		# inmenu
		atarget = MainMenu.instance._on_audio_drag_ended
		mtarget = MainMenu.instance._on_music_drag_ended
	else:
		# ingame
		atarget = World.instance._on_audio_drag_ended
		mtarget = World.instance._on_music_drag_ended
	$Audio.connect("drag_ended", atarget)
	$Music.connect("drag_ended", mtarget)
