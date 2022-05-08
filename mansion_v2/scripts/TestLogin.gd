extends Control

onready var user = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/user")
onready var server = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/server")
onready var http_request = HTTPRequest.new()
onready var http_request_update = HTTPRequest.new()

var host = "" #this will be changed later
var player_list_local = []
func _ready():
	#HTTP request node
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	add_child(http_request_update)
	http_request_update.connect("update_request", self, "_update_request_complete")
	
	
	
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	if response != null and response.has("server"):
		print(response["server"])
		host = response["server"]
		$PanelContainer/MarginContainer/VBoxContainer/GridContainer/server.text = host
	elif response != null and response.has("player_list"):
		$PanelContainer/MarginContainer/VBoxContainer/Login_list.text = $PanelContainer/MarginContainer/VBoxContainer/Login_list.text
		print("received")
		player_list_local = response["player_list"]

func _on_Join_pressed():
	var fields = {"username" : user.text, "server" : server.text}
	var result = http_request.request("http://127.0.0.1:5000/join", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")

func _on_Host_pressed():
	var fields = {"username" : user.text, "empty" : "empty"}
	var result = http_request.request("http://127.0.0.1:5000/host", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")



func _process(delta):
	var fields = {"server" : host, "request" : "update_list"}
	if host != "":
		var result = http_request.request("http://127.0.0.1:5000/update", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	$PanelContainer/MarginContainer/VBoxContainer/Login_list.text = "Login - Test Screen"
	for elem in player_list_local:
		$PanelContainer/MarginContainer/VBoxContainer/Login_list.text += "\n" + elem
	
