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

###############################################################################
# Tracks Global Input to perform Non Situational Inputs #######################
###############################################################################
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_TAB:
			#get_tree().quit() #was causing 
			pass
