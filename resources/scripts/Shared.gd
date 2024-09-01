extends Node

enum GAMEMODE {
	NORMAL, ENDLESS
}

var _gamemode = GAMEMODE.ENDLESS
var settings = {}
var config = ConfigFile.new()

func _ready():
	var error = config.load("user://settings.cfg")

	if error != OK:
		_save_settings()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()

func _save_settings():
	var error = config.save("user://settings.cfg")
	if error != OK:
		print("Failed trying to save settings! error: %d" % [error])

func update_music():
	get_parent().get_node("MusicPlayer").volume_db = get_mus_vol()
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
func set_mus_vol(new: float):
	config.set_value("Audio", "music", new)
