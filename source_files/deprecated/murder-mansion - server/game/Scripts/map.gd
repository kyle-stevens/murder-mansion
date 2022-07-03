extends Spatial

var player = preload("res://Scenes/player_instance.tscn")
var _player_name = "player_"

func _ready():
	#not working
	
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Global.connect("instance_player", self, "_instance_player")
	
	
	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)
	
func _instance_player(id):

	
	print("Player Created with ID: "+str(id))
	var player_instance = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	add_child(player_instance)
	player_instance.global_transform.origin = Vector3(0,5,5)
	

func _player_connected(id):
	print("Player " + str(id) + " has connected.")
	
	_instance_player(id)
	
func _player_disconnected(id):
	print("Player "+str(id)+" has disconnected")
	
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _on_PlayerName_text_changed(new_text):
	_player_name = new_text
	PlayerVariables.player_name = new_text
	print(_player_name)

func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		PlayerVariables.player_model = "Male"
	else:
		PlayerVariables.player_model = "Female"
