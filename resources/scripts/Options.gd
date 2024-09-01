extends Control


func _ready():
	for i in range(1):
		await get_tree().process_frame
	
	var atarget
	var mtarget
	var btarget
	var m = MainMenu
	var i = MainMenu.instance
	print(i)
	if MainMenu.instance != null:
		# inmenu
		atarget = MainMenu.instance._on_audio_drag_ended
		mtarget = MainMenu.instance._on_music_drag_ended
		btarget = MainMenu.instance._on_back_pressed
	else:
		# ingame
		#atarget = World.instance._on_audio_drag_ended
		#mtarget = World.instance._on_music_drag_ended
		breakpoint
		return
	$Audio.connect("drag_ended", atarget)
	$Music.connect("drag_ended", mtarget)
	$Back.connect("pressed", btarget)
	print("connected options!")
