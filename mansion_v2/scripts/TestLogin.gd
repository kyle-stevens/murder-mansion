extends Control

onready var user = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/user")
onready var server = get_node("PanelContainer/MarginContainer/VBoxContainer/GridContainer/server")
onready var http_request = HTTPRequest.new()

var host = "" #this will be changed later

func _ready():
	#HTTP request node
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response)

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
