extends Control

var _player_name = "Player"

func _ready():
	Global.connect("toggle_network_setup",self,"_toggle_network_setup")

func _on_IpAddress_text_changed(new_text):
	Network.ip_address = new_text


func _on_Host_pressed():
	
#	hide()
#	Global.emit_signal("instance_player", get_tree().get_network_unique_id())
#Still trying to figure out dedicated server stuff
	if _player_name == "dedicated_server":
		Network.create_server()
		print("DEDICATED SERVER")
		hide()
	else:
		Network.create_server()
		hide()
		#Global.emit_signal("instance_player", get_tree().get_network_unique_id()) #setting up only dedicated server system

func _on_Join_pressed():
	Network.join_server()
	hide()
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())

func _toggle_network_setup(visible_toggle):
	visible = visible_toggle
	
func _on_PlayerName_text_changed(new_text):
	_player_name = new_text
	#print(_player_name)
