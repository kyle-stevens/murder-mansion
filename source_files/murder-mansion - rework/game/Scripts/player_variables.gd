###############################################################################
# Global Player Variable ######################################################
###############################################################################

extends Node

###PLAYER GLOBAL VARIABLES#####################################################

# Player Model Selected (Defaults to Female)
var player_model : String = "Female"

# Player Name Selected (Defaults to 'Victim')
var player_name : String = "Victim"

# Color for Player Model (Defaults to Red, will be changed based on Lobby
# State)
var player_color : String = "res://Assets/player_materials/Red.tres"

# Player Hat String (Defaults to Empty)
var player_hat : String = ""

# Player Camera, used to maintaint singular Camera Node among all
# PlayerInstance nodes
var player_active_camera : Camera
