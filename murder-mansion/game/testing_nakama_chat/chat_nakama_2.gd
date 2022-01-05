extends Node

onready var server_connection := $chat_nakama
onready var debug_panel := $debug


func _ready():
	var email := "test@test.com"
	var password := "password"
	
	debug_panel.text = "Authenticating"
	var result : int = yield(server_connection.authenticate_async(email,password), "completed")
	
	if result == OK:
		debug_panel.text = "authenticated"
	else:
		debug_panel.text = "not authenticated"
