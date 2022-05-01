extends KinematicBody

var player_name = ""

#Animation Vars
var current_animation = "default"
onready var anim_player #grab player model animation player

#Movement Vars
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8

var vel = Vector3()
var dir = Vector3()

const JUMP_SPEED = 9
const GRAVITY = -24.8

const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18

#Flashlight Vars
onready var flashlight = get_node("rotation_helper/flashlight")

#Weapon Vars
var weapon_active = null

#Rotation Vars
onready var rotation_helper = get_node("rotation_helper")
export var mouse_sensitivity = 0.05

#UI Vars

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _input(event):
	pass
