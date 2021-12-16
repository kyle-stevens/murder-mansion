extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")


func _on_HostButton_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(6000, 5)
	get_tree().network_peer = net
	print("hosting")


func _on_JoinButton_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client("127.0.0.1", 6000)
	get_tree().network_peer = net
	
func _player_connected(id):
	Globals.player2id = id
	var game = preload("res://Scenes/Maps/PlatformDemo.tscn").instance()
	get_tree().get_root().add_child(game)
	print("player joined")
	hide()
