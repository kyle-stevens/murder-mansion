extends KinematicBody

var player_name = ""

###CONSTANTS###################################################################
const ACCEL = 4.5
const DEACCEL = 16
const SPRINT_ACCEL = 18
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8
const MAX_SPRINT_SPEED = 15
const JUMP_SPEED = 9
const GRAVITY = -24.8

###PUPPET VARIABLES############################################################
var puppet_name : String = ""
var puppet_pos : Vector3 = Vector3()
var puppet_vel : Vector3 = Vector3()
var puppet_rot : Vector2 = Vector2()
var puppet_flash : bool = true
var puppet_anim : String = "animationIdle"
var puppet_model : String = ""
export(NodePath) onready var movement_tween = get_node("movement_tween") as Tween
export(NodePath) onready var network_tick_rate = get_node("network_tick_rate") as Timer

###ANIMATION###################################################################
var animation_player : AnimationPlayer
var current_animation : String

###MOVEMENT####################################################################
var is_sprinting : bool
var vel : Vector3 = Vector3()
var dir : Vector3 = Vector3()
var sprint_energy : int
var sprint_recharge : bool

###FLASHLIGHT##################################################################
var flashlight : SpotLight

###CAMERA######################################################################
onready var camera = get_node("rotation_helper/player_camera")
export var x_range = 70

###ROTATION HELPER#############################################################
onready var rotation_helper = get_node("rotation_helper")
export var mouse_sensitivity = 0.05

###UI##########################################################################
var reticle : String #Not yet implemented

###PLAYER MODEL################################################################
onready var player_model = get_node("player_model")
var init

func _ready():
#	#Check if Instance is Network Master for Camera Focus
#	camera.current = is_network_master()
#
#	#Set Model for Player
#	if is_network_master():
#		if PlayerVariables.player_model == "Male":
#			var instance = load("res://Scenes/ybot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
#		elif PlayerVariables.player_model == "Female":
#			var instance = load("res://Scenes/xbot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
#	else:
#		if puppet_model == "Male":
#			var instance = load("res://Scenes/ybot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
#		elif puppet_model == "Female":
#			var instance = load("res://Scenes/xbot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
#
#	#Getting Flashlight Node from player_model child
#	flashlight = get_node("player_model/player_model/Skeleton/"+
#		"FlashlightAttachment/flashlight/SpotLight")
#
#	#Getting Animation Node from player_model child
#	animation_player = get_node("player_model/player_model/AnimationPlayer")
#
#	#Set Initial Animation
#	animation_player.play("animationIdle")
#
#	#Initial Mouse Mode
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
#	#Set Sprint Energy
#	sprint_energy = 100
#	sprint_recharge = false
	pass
	init = false

func initFunc():
	#Check if Instance is Network Master for Camera Focus
	camera.current = is_network_master()

	#Set Model for Player
	if is_network_master():
		if PlayerVariables.player_model == "Male":
			var instance = load("res://Scenes/ybot.tscn").instance()
			instance.set_name("player_model")
			player_model.add_child(instance)
		elif PlayerVariables.player_model == "Female":
			var instance = load("res://Scenes/xbot.tscn").instance()
			instance.set_name("player_model")
			player_model.add_child(instance)
	else:
		if puppet_model == "Male":
			var instance = load("res://Scenes/ybot.tscn").instance()
			instance.set_name("player_model")
			player_model.add_child(instance)
		elif puppet_model == "Female":
			var instance = load("res://Scenes/xbot.tscn").instance()
			instance.set_name("player_model")
			player_model.add_child(instance)

	#Getting Flashlight Node from player_model child
	flashlight = get_node("player_model/player_model/Skeleton/"+
		"FlashlightAttachment/flashlight/SpotLight")

	#Getting Animation Node from player_model child
	animation_player = get_node("player_model/player_model/AnimationPlayer")

	#Set Initial Animation
	animation_player.play("animationIdle")

	#Initial Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	#Set Sprint Energy
	sprint_energy = 100
	sprint_recharge = false
	init = true

func _physics_process(delta):
	if not init:
		initFunc()
	process_inputs(delta)
	process_movement(delta)

func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion and \
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(
					deg2rad(event.relative.y*mouse_sensitivity * 1))
					#change to 1 for inverted mouse up/dwn
			self.rotate_y(
					deg2rad(event.relative.x*mouse_sensitivity * -1))
					#change to 1 for inverted mouse left/right

			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -x_range, x_range)

			rotation_helper.rotation_degrees = camera_rot

func process_inputs(delta):
		#make sprint energy a bar
		if is_network_master():
			#Handling Sprint Recharge Mechanic
			if sprint_recharge:
				if sprint_energy <= 50:
					is_sprinting = false
				else:
					sprint_recharge = false
			else:
				if sprint_energy <= 0:
					is_sprinting = false
					sprint_recharge = true
			if sprint_energy > 100:
				sprint_energy = 100

			#Purely for demo instancing of player
			#print(vel)

			#Check if Jumping
			if is_on_floor(): #keeps motion while in jump
				dir = Vector3()

			#Camera Transform
			var cam_xform = camera.get_global_transform()

			#Set Input Movement
			var input_movement_vector = Vector2()

			#Booleans for Movement
			var forward = false
			var backward = false
			var left = false
			var right = false


			if Input.is_action_pressed("movement_forward"):
				input_movement_vector.y += 1
				forward = true
			if Input.is_action_pressed("movement_backward"):
				input_movement_vector.y -= 1
				backward = true
			if Input.is_action_pressed("movement_left"):
				input_movement_vector.x -= 1
				left = true
			if Input.is_action_pressed("movement_right"):
				input_movement_vector.x += 1
				right = true

			if not is_sprinting:
				sprint_energy += 1
				if forward and is_on_floor():
					if left:
						animation_player.play("animationLeftStrafeWalk")
					elif right:
						animation_player.play("animationRightStrafeWalk")
					else:
						animation_player.play("animationWalk")
				elif backward and is_on_floor():
					if left:
						animation_player.play_backwards("animationRightStrafeWalk")
					elif right:
						animation_player.play_backwards("animationLeftStrafeWalk")
					else:
						animation_player.play_backwards("animationWalk")
				elif left and is_on_floor():
					animation_player.play("animationLeftStrafeWalk")
				elif right and is_on_floor():
					animation_player.play("animationRightStrafeWalk")
			elif is_sprinting:
				sprint_energy -= 1
				if forward and is_on_floor():
					if left:
						animation_player.play("animationLeftStrafeRun")
					elif right:
						animation_player.play("animationRightStrafeRun")
					else:
						animation_player.play("animationRun")
				elif backward and is_on_floor():
					if left:
						animation_player.play_backwards("animationRightStrafeRun")
					elif right:
						animation_player.play_backwards("animationLeftStrafeRun")
					else:
						animation_player.play_backwards("animationRun")
				elif left and is_on_floor():
					animation_player.play("animationLeftStrafeRun")
				elif right and is_on_floor():
					animation_player.play("animationRightStrafeRun")



			if abs(vel.x) < 1 and abs(vel.y) < 1 and abs(vel.z) < 1 and is_on_floor():
				animation_player.play("animationIdle")
			if not is_on_floor():
				animation_player.play("animationFalling")
			input_movement_vector = input_movement_vector.normalized()

			dir += -cam_xform.basis.z * input_movement_vector.y
			dir += cam_xform.basis.x * input_movement_vector.x

			#Jump Movement
			if is_on_floor():
				if Input.is_action_just_pressed("movement_jump"):
					vel.y = JUMP_SPEED
					animation_player.play("animationFalling")

			#Cursor Freeing
			if Input.is_action_just_pressed("ui_cancel"):
				print("cursor freeing")
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			#Flashlight Toggle
			if Input.is_action_just_pressed("player_flashlight"):
				if flashlight.visible == true:
					flashlight.visible = false
				else:
					flashlight.visible = true

			#Sprinting Movement
			if Input.is_action_pressed("movement_sprint"):
				is_sprinting = true
			else:
				is_sprinting = false

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAVITY
	if is_network_master():
		var hvel = vel
		hvel.y = 0
		var target = dir
		#target *= MAX_SPEED
		if is_sprinting:
			target *= MAX_SPRINT_SPEED
		else:
			target *= MAX_SPEED
		var accel
		if dir.dot(hvel) > 0:
			if is_sprinting:
				accel = SPRINT_ACCEL
			else:
				accel = ACCEL
		else:
			accel = DEACCEL
		hvel = hvel.linear_interpolate(target, accel * delta)
		vel.x = hvel.x
		vel.z = hvel.z
	else:
		global_transform.origin = puppet_pos
		animation_player.play(puppet_anim)
		vel.x = puppet_vel.x
		vel.z = puppet_vel.z
		rotation.y = puppet_rot.y
		camera.rotation.x = puppet_rot.x
		flashlight.visible = puppet_flash



	if !movement_tween.is_active():
		vel = move_and_slide(
				vel,
				Vector3(0,1,0),
				0.05,
				4,
				deg2rad(MAX_SLOPE_ANGLE)
				)

remote func _set_position(pos):
	global_transform.origin = pos

puppet func update_state(p_position, p_velocity, p_rotation, p_flashlight_on, p_animation, p_player_name, p_player_model, held_object_position):
	puppet_pos = p_position
	puppet_rot = p_rotation
	puppet_vel = p_velocity
	puppet_flash = p_flashlight_on
	puppet_anim = p_animation
	puppet_name = p_player_name #player username
	puppet_model = p_player_model
	movement_tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis, p_position), 0.1)
	movement_tween.start()
	
#	#Check for host model
#	if puppet_model != PlayerVariables.player_model:
#		player_model.get_node("player_model").queue_free()
#		####HERE IS THE RESET!!
#		if puppet_model == "Male":
#			var instance = load("res://Scenes/ybot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
#		elif puppet_model == "Female":
#			var instance = load("res://Scenes/xbot.tscn").instance()
#			instance.set_name("player_model")
#			player_model.add_child(instance)
	
func _on_network_tick_rate_timeout():
	print("timeout")
	if is_network_master():
		print("timeout")
		rpc_unreliable("update_state", global_transform.origin, vel, Vector2(camera.rotation.x, rotation.y), flashlight.visible, animation_player.current_animation, PlayerVariables.player_name, PlayerVariables.player_model, "none")
	else:
		network_tick_rate.stop()

