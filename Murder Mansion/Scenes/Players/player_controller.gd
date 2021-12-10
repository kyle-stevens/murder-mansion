extends KinematicBody

#Death Variables
var is_dead = false

#Basic Movement
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8
var vel = Vector3()
var dir = Vector3()

#Jump Movement
const JUMP_SPEED = 9
var gravity = -24.8

#Flashlight
var flashlight

#Camera
var camera
export var x_range = 70

#Grabbing Objects(RigidBodys)
var grabbed_object = null
export var OBJECT_THROW_FORCE = 120 #change to const upon balancing
export var OBJECT_GRAB_DISTANCE = 7 #change to const upon balancing
export var OBJECT_GRAB_RAY_DISTANCE = 10 #change to const upon balancing
var object_detection
var object_detection_collision
var objectToThrowVar

#Rotation Helper
var rotation_helper
export var MOUSE_SENSITIVITY = 0.05

#UI
var reticle

func _ready():
	#Camera Setup
	camera = $rotation_helper/player_camera #set camera variable to camera node
	camera.current = true
	
	#Flashlight Setup
	flashlight = $player_light
	
	#UI
	reticle = $player_hud/crosshair
	reticle.set_position(get_viewport().size / 2)
	
	#Animation Setup
	
	
	#Initial Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

