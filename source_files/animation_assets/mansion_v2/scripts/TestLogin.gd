extends Control

onready var error_message = get_node("PanelContainer/MarginContainer/VBoxContainer/Request_Message")
onready var user = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/user")
onready var password = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/password")
onready var http_request = HTTPRequest.new()
const SERVER = "http://192.168.5.119:5000" #"http://127.0.0.1:5000"

func _ready():
	#HTTP request node
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
		
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	
	if response['status'] == "LOGIN_OK":
		#set global vars in PlayerInfo
		PlayerData.username = user.text
		get_tree().change_scene("res://scenes/BasicChat.tscn")
	else:
		error_message.text = response['status']

func _on_Login_pressed():
	var fields = {"username" : user.text, "password" : password.text}
	var result = http_request.request(SERVER + "/login", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")


func _on_Register_pressed():
	var fields = {"username" : user.text, "password" : password.text}
	var result = http_request.request(SERVER + "/register", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")
