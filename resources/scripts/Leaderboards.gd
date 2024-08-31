# why would you cheat in a game this bad quality

extends Node
class_name Leaderboards

static var instance

var game_API_key = "dev_abda0ec58a954d5c980b26c5edc08f9c"
var development_mode = true
var leaderboard_key = "score"
var session_token = ""

var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

func _ready():
	instance = self
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
	auth_http.request_completed.connect(_on_authentication_request_completed)
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	

func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print(body.get_string_from_utf8())
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.get_data().player_identifier)
	file.close()
	
	session_token = json.get_data().session_token
	print(json.get_data())
	
	auth_http.queue_free()
	_get_leaderboards()


func _get_leaderboards():
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print(body.get_string_from_utf8())
	var leaderboardFormatted = ""
	for n in json.get_data().items.size():
		leaderboardFormatted += str(json.get_data().items[n].rank)+str(". ")
		leaderboardFormatted += str(json.get_data().items[n].player.id)+str(" - ")
		leaderboardFormatted += str(json.get_data().items[n].score)+str("\n")
	print(leaderboardFormatted)
	leaderboard_http.queue_free()


func _upload_score(score: int):
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print(json.get_data())
	submit_score_http.queue_free()
