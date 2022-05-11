extends Control

var timer

onready var chat_mesgs = get_node("PanelContainer/VBoxContainer/HBoxContainer2/chat_mesgs")
onready var user_list = get_node("PanelContainer/VBoxContainer/HBoxContainer2/user_list")
onready var mesg = get_node("PanelContainer/VBoxContainer/HBoxContainer/mesg")

onready var http_request = HTTPRequest.new()
const SERVER = "http://192.168.5.119:5000"#"http://127.0.0.1:5000"

func _ready():
	#HTTP request node
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	user_list.text = user_list.text + "\n" + PlayerData.username
	
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	#timeout is what says in docs, in signals
	#self is who respond to the callback
	#_on_timer_timeout is the callback, can have any name
	add_child(timer) #to process
	timer.start(0.5) #to start

func _on_timer_timeout():
	timer.start(0.5) #to start
	var fields = {"type" : "update", "username" : PlayerData.username}
	var result = http_request.request(SERVER + "/chat_test", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")

func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	#print(response)
	
	if response['status'] == "MESG_RECEIVED":
		pass
	else:
		user_list.text = "USERS:\n"
		for user in response['list']:
			user_list.text = user_list.text + user + "\n"
		chat_mesgs.text = response['mesg']

func _on_Button_pressed():
	var fields = {"type" : "send", "mesg" : mesg.text, "username" : PlayerData.username}
	mesg.text = ""
	print(fields)
	var result = http_request.request(SERVER + "/chat_test", PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))
	if result != OK:
		push_error("An error occurred in the HTTP request")


	
	
