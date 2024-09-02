extends Node

enum GAMEMODE {
	NORMAL, ENDLESS
}

var _gamemode = GAMEMODE.ENDLESS
var config = ConfigFile.new()
var loaded_settings = false

var cheats_enabled = false
var freaky_mode = false
var testing_android = false

var is_mobile = OS.get_name() == "Android" or (OS.is_debug_build() and testing_android)

func _ready():
	_load_settings()
	set_process(true)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()

func _load_settings():
	if loaded_settings:
		return
	loaded_settings = true
	var error = config.load("user://settings.cfg")
	
	if error != OK:
		_save_settings()

func _save_settings():
	var error = config.save("user://settings.cfg")
	if error != OK:
		print("Failed trying to save settings! error: %d" % [error])

func _process(_delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), get_aud_vol())
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), get_mus_vol())

func get_gamemode():
	return _gamemode
func get_real_aud_vol() -> int:
	return config.get_value("Audio", "audio", 100)
func get_real_mus_vol() -> int:
	return config.get_value("Audio", "music", 100)
func get_aud_vol() -> float:
	var volume = get_real_aud_vol()
	if volume == 0:
		return -1000
	var normalized_volume = clamp(volume / 100.0, 0.01, 1)
	return 20 * (log(normalized_volume) / log(10))
func get_mus_vol() -> float:
	var volume = get_real_mus_vol()
	if volume == 0:
		return -1000
	var normalized_volume = clamp(volume / 100.0, 0.01, 1)
	return 20 * (log(normalized_volume) / log(10))
func set_aud_vol(new: float):
	config.set_value("Audio", "audio", new)
	_save_settings()
func set_mus_vol(new: float):
	config.set_value("Audio", "music", new)
	_save_settings()
