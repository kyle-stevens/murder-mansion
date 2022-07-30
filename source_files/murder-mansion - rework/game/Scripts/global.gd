###############################################################################
# Global Variable Script : ####################################################
###############################################################################

extends Node

###SIGNALS#####################################################################
signal instance_player(id)
signal toggle_network_setup(toggle)
signal start_game

###VARIABLES###################################################################
var map_code : int = 0
var game_started : bool = false
var colors = {"Black" : 0, "Blue" : 0, "Brown" : 0, "Green" : 0, "Purple" : 0, 
			"Red" : 0, "Teal" : 0, "White" : 0, "Yellow" : 0}

###############################################################################
# Tracks Global Input to perform Non Situational Inputs #######################
###############################################################################
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_TAB:
			#get_tree().quit() #was causing 
			pass

func _process(delta):
	print(colors)
