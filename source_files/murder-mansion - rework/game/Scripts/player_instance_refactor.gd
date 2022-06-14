###############################################################################
# PlayerInstance Script : #####################################################
###############################################################################

extends KinematicBody

###CONSTANTS###################################################################
const ACCEL = 4.5
const DEACCEL = 16
const SPRINT_ACCEL = 18
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8
const MAX_SPRINT_SPEED = 15
const JUMP_SPEED = 15 #9
const GRAVITY = -24.8

###PUPPET VARIABLES############################################################
var puppet_name : String = ""
var puppet_pos : Vector3 = Vector3()
var puppet_vel : Vector3 = Vector3()
var puppet_rot : Vector2 = Vector2()
var puppet_flash : bool = true
var puppet_anim : String = "animationIdle"
var puppet_model : String = ""
var puppet_color : String = ""
var puppet_hat : String = ""
var puppet_nametag : String
var puppet_alive : bool = true

export(NodePath) onready var movement_tween = \
	get_node("movement_tween") as Tween
export(NodePath) onready var network_tick_rate = \
	get_node("network_tick_rate") as Timer

###ANIMATION###################################################################
var animation_player : AnimationPlayer
var current_animation : String

###PLAYER VARIABLES############################################################
######MOVEMENT#################################################################
var is_sprinting : bool
var vel : Vector3 = Vector3()
var dir : Vector3 = Vector3()
var sprint_energy : int
var sprint_recharge : bool

######FLASHLIGHT###############################################################
var flashlight : SpotLight

######CAMERA###################################################################
onready var camera = get_node("rotation_helper/player_camera")
export var x_range = 25

######ROTATION HELPER##########################################################
onready var rotation_helper = get_node("rotation_helper")
export var mouse_sensitivity = 0.05

######UI#######################################################################
var reticle : String #Not yet implemented

######PLAYER MODEL#############################################################
onready var player_model = get_node("player_model")

###HELPER VARIABLES FOR NETWORKING#############################################
var init : bool = false

###############################################################################
# Ready Function called on Scene creation and instancing, enables the camera ##
# and sets up UI for network master scene. ####################################
###############################################################################
func _ready():
	# Connect the _start_game function which will generate a map code from a
	# chosen seed (yet to be implemented)
	Global.connect("start_game",self,"_start_game")
	
	# Enable and/or disable ui based on whether player is/isn't the network
	# master player
	if is_network_master():
		PlayerVariables.player_active_camera = camera
		var center = Vector2(1280.0/2.0, 720.0/2.0)
		$UI/popupMesg.set_position(Vector2(
			center.x - ($UI/popupMesg.rect_size.x), 150.0), false)
		# Rect_size.x instead of Rectsize.x/2 bc of scaling of label
		
		$UI/popupMesg.text = ""
	else:
		$UI.visible = false

###############################################################################
# Called every delta iteration looping to maintain player model appearance ####
# and update when player color/model is changed ###############################
###############################################################################
func updateAppearance():
	if is_network_master():
		var player_model_surface_colors
		
		# Determine which model the player is using
		if PlayerVariables.player_model == "Female":
			player_model_surface_colors = \
				player_model.get_node("./player_model/Skeleton/Beta_Surface")
		else:
			player_model_surface_colors = \
				player_model.get_node("./player_model/Skeleton/Alpha_Surface")
				
		player_model_surface_colors.set_surface_material(
		0,load(PlayerVariables.player_color)
		)
		
		# Set Hat models for player
		if PlayerVariables.player_hat != "":
			player_model.get_node(
				"player_model/Skeleton/HeadAttachment/MeshInstance"
				).mesh = load(PlayerVariables.player_hat)
	else:
		var player_model_surface_colors
		
		# Determine which model the puppet is using
		if puppet_model == "Female":
			player_model_surface_colors = \
				player_model.get_node("./player_model/Skeleton/Beta_Surface")
		else:
			player_model_surface_colors = \
				player_model.get_node("./player_model/Skeleton/Alpha_Surface")
				
		player_model_surface_colors.set_surface_material(0,load(puppet_color))
		
		# Set Hat for puppet
		if puppet_hat != "":
			player_model.get_node(
				"player_model/Skeleton/HeadAttachment/MeshInstance"
				).mesh = load(puppet_hat)
