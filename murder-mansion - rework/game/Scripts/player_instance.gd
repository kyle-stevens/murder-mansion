extends KinematicBody

###CONSTANTS###################################################################
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8
const SPRINT_SPEED = 15

const JUMP_SPEED = 9
const GRAVITY = -24.8

###PUPPET VARIABLES############################################################
var puppet_vel : Vector3
var puppet_rot : Vector3
var puppet_flash : bool
var puppet_anim : String

###ANIMATION###################################################################
onready var animation_player = get_node("player_model/*/AnimationPlayer")




# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
