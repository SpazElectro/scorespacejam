# why would you cheat in a game this bad quality

extends Node

var game_API_key = "dev_abda0ec58a954d5c980b26c5edc08f9c"
var development_mode = true
var leaderboard_key = "score"
var session_token = ""

var authenticated = false

var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

func _ready():
	_authentication_request()

func _authentication_request():
	var player_session_exists = false
	var player_identifier : String
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	if file != null:
		player_identifier = file.get_as_text()
		print("player ID="+player_identifier)
		file.close()
 
	if player_identifier != null and player_identifier.length() > 1:
		print("player session exists, id="+player_identifier)
		player_session_exists = true
	if player_identifier.length() > 1:
		player_session_exists = true
		
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }
	
	if player_session_exists == true:
		data = { "game_key": game_API_key, "player_identifier":player_identifier, "game_version": "0.0.0.1", "development_mode": true }
	
	var headers = ["Content-Type: application/json"]
	
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	var response = await auth_http.request_completed
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var file2 = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file2.store_string(json.get_data().player_identifier)
	file2.close()
	
	session_token = json.get_data().session_token
	auth_http.queue_free()
	authenticated = true

func _get_leaderboards(tries=0):
	if not authenticated:
		await get_tree().process_frame
		await get_tree().process_frame
	if tries == 3:
		return null
	
	var url = "https://api.lootlocker.io/game/leaderboards/" + leaderboard_key + "/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:" + session_token]
	
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	
	var result = leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")
	if result != OK:
		print("Failed to make request.")
		return ""
	
	var response = await leaderboard_http.request_completed
	
	var response_code = response[1]
	var body = response[3]
	
	if response_code == 403:
		print("Forbidden request.")
		return await _get_leaderboards(tries+1)
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("Failed to parse JSON.")
		return await _get_leaderboards(tries+1)
	
	return json.get_data()

func _upload_score(score: int):
	if Shared.did_freaky_mode or Shared.freaky_mode or Shared.cheats_enabled:
		return
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_upload_score_request_completed(_result, _response_code, _headers, body) :
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
