# Typical lobby implementation; imagine this being in /root/lobby.

extends Node

# Connect all functions

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here











#extends Node2D
#
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	get_tree().connect("network_peer_connected", self, "_player_connected")
#
#
#func _on_HostButton_pressed():
#	var net = NetworkedMultiplayerENet.new()
#	net.create_server(6000, 5)
#	get_tree().network_peer = net
#	print("hosting")
#
#
#func _on_JoinButton_pressed():
#	var net = NetworkedMultiplayerENet.new()
#	net.create_client("127.0.0.1", 6000)
#	get_tree().network_peer = net
#
#func _player_connected(id):
#	Globals.player2id = id
#	var game = preload("res://Scenes/Maps/PlatformDemo.tscn").instance()
#	get_tree().get_root().add_child(game)
#	print("player joined")
#	hide()
