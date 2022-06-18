###############################################################################
# Network Setup Script : ######################################################
###############################################################################

extends Control

###NETWORK SETUP VARIABLES#####################################################
var _player_name = "Player"

###############################################################################
# Built-in Ready Function when Network Setup is called ########################
###############################################################################
func _ready():
	Global.connect("toggle_network_setup",self,"_toggle_network_setup")

###############################################################################
# Handling Host button 'pressed' signal #######################################
###############################################################################
func _on_Host_pressed():
	# If the Player Name is 'dedicated_server'. This is likely to be deprecated
	# and removed at a later date
	if _player_name == "dedicated_server":
		Network.create_server()
		# hide the ui console menu
		hide()
		# Do not instance a player for the dedicated server
	else:
		Network.create_server()
		# hide the ui console menu
		hide()
		Global.emit_signal("instance_player",
			get_tree().get_network_unique_id())

###############################################################################
# Handling Join button 'pressed' signal #######################################
###############################################################################
func _on_Join_pressed():
	Network.join_server()
	hide()
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())

###############################################################################
# Handling the network setup menu toggle ######################################
###############################################################################
func _toggle_network_setup(visible_toggle):
	visible = visible_toggle

###############################################################################
# Monitor the player name for in game nickname ################################
###############################################################################
func _on_PlayerName_text_changed(new_text):
	_player_name = new_text
	#print(_player_name)
