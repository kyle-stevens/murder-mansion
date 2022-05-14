extends KinematicBody

var player_name = ""

###CONSTANTS###################################################################
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8#15
const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18
const JUMP_SPEED = 9
const GRAVITY = -24.8

###PUPPET VARIABLES############################################################
var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()
var puppet_flashlight = true
var puppet_animation = "default"


###NETWORKING##################################################################
export(NodePath) onready var network_tick_rate = get_node("network_tick_rate") as Timer
export(NodePath) onready var movement_tween = get_node("movement_tween") as Tween

var dead = false #deprecated for now

###MOVEMENT####################################################################
var vel = Vector3()
var dir = Vector3()
var is_sprinting = false

###FLASHLIGHT##################################################################
var flashlight

###CAMERA######################################################################
export var x_range = 70
onready var camera = get_node("rotation_helper/player_camera") as Camera
onready var head = get_node("rotation_helper")

###ROTATION HELPER#############################################################
var rotation_helper
export var MOUSE_SENSITIVITY = 0.05

###UI##########################################################################
var reticle

###ANIMATION###################################################################
var model
var animation_player

func _ready():

	camera.current = is_network_master()

	#Rotation Helper
	rotation_helper = $rotation_helper

	#UI
	#reticle = $player_hud/Reticle
	#reticle.set_position(get_viewport().size / 2)
	#Change Var for Color Shift
	#reticle = $player_hud/Reticle/ColorRect

	#Set Model for Player
	if PlayerVariables.player_model == "Male":
		var instance = load("res://Scenes/ybot.tscn").instance()
		instance.set_name("player_model")
		player_model.add_child(instance)
	elif PlayerVariables.player_model == "Female":
		var instance = load("res://Scenes/xbot.tscn").instance()
		instance.set_name("player_model")
		player_model.add_child(instance)


	#ANIMATION
	animation_player = get_node("player_model/player_model/AnimationPlayer")
	animation_player.play("animationIdle")

	flashlight = get_node("player_model/player_model/Flashlight/SpotLight")

	#Initial Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _physics_process(delta):
	if Input.is_action_just_pressed("camera"):
		if camera.transform.origin == Vector3(0,1.4,4.4):
			camera.transform.origin = Vector3(0,1.4,0)
		else:
			camera.transform.origin = Vector3(0,1.4,4.4)


	if dead:
		#GRAVITY = 0
		pass

	process_inputs(delta)
	process_movement(delta)

	if object_name != "none": #change to a check if the value has changed
		var node_Test = get_tree().get_root().get_node(object_name)
		#print(node_Test)



func _input(event):
	if is_network_master():
		#Purely for demo instancing of player
		#print(vel)

		if event is InputEventMouseMotion and \
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(
					deg2rad(event.relative.y*MOUSE_SENSITIVITY * -1))
					#change to 1 for inverted mouse up/dwn
			self.rotate_y(
					deg2rad(event.relative.x*MOUSE_SENSITIVITY * -1))
					#change to 1 for inverted mouse left/right

			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -x_range, x_range)

			rotation_helper.rotation_degrees = camera_rot


func process_inputs(delta):
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

			#Basic Movement - only way to avoid animation glitch is elif statements instead of all ifs
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

			#handlingAnimations - walk has been exchanged with slow run
			if forward and is_on_floor():
				if left:
					animation_player.play("leftstrafe")
				elif right:
					animation_player.play("rightstrafe")
				else:
					animation_player.play("walk")
			elif backward and is_on_floor():
				if left:
					animation_player.play_backwards("rightstrafe")
				elif right:
					animation_player.play_backwards("leftstrafe")
				else:
					animation_player.play_backwards("walk")
			elif left and is_on_floor():
				animation_player.play("leftstrafe")
			elif right and is_on_floor():
				animation_player.play("rightstrafe")



			if abs(vel.x) < 1 and abs(vel.y) < 1 and abs(vel.z) < 1 and is_on_floor():
				animation_player.play("default")
			if not is_on_floor():
				animation_player.play("jump")
			input_movement_vector = input_movement_vector.normalized()

			dir += -cam_xform.basis.z * input_movement_vector.y
			dir += cam_xform.basis.x * input_movement_vector.x

			#Jump Movement
			if is_on_floor():
				if Input.is_action_just_pressed("movement_jump"):
					vel.y = JUMP_SPEED
					animation_player.play("jump")

			#Cursor Freeing
			if Input.is_action_just_pressed("ui_cancel"):
				print("cursor freeing")
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			#Flashlight Toggle
			if Input.is_action_just_pressed("player_flashlight"):
				#var flashlight = $rotation_helper/player_flashlight
				if flashlight.visible == true:
					flashlight.visible = false
				else:
					flashlight.visible = true

			#Sprinting Movement
			if Input.is_action_pressed("movement_sprint"):
				is_sprinting = true
				pass
				#sprinting removed for the moment
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
		global_transform.origin = puppet_position
		animation_player.play(puppet_animation)
		vel.x = puppet_velocity.x
		vel.z = puppet_velocity.z
		rotation.y = puppet_rotation.y
		head.rotation.x = puppet_rotation.x
		flashlight.visible = puppet_flashlight



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


func _on_Area_body_exited(body):
	#Remove Highlight on RigidBody
	if body is RigidBody:
		var CSGSPHERE : Node = body.get_node("CSGSphere")
		#CSGSPHERE.material_override = \
		#load("res://Shaders_and_Materials/plain_white_material.tres")

		#print(CSGSPHERE)
		#reticle.color = Color(1,1,1,1)
	pass
	pass # Replace with function body.


func _on_damage_area_body_entered(body):
	if body is RigidBody and body.damage != 0 and body.thrower != self:
		#self.reticle.color = Color(1,0,0,1)
		print("Damaged")
		animation_player.play("death")
		$collision_body.queue_free()
		$collision_feet.queue_free()
		$rotation_helper.queue_free()
		$player_hud.queue_free()
		$damage_area.queue_free()
		get_tree()
		dead = true
		#queue_free() or spectator mode
		#Make Ghost instance
		body.queue_free()
		#implement damage here


puppet func update_state(p_position, p_velocity, p_rotation, p_flashlight_on, p_animation, p_player_name, held_object_name, held_object_position):
	puppet_position = p_position
	puppet_rotation = p_rotation
	puppet_velocity = p_velocity
	puppet_flashlight = p_flashlight_on
	puppet_animation = p_animation
	player_name = p_player_name #player username
	movement_tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis, p_position), 0.1)
	movement_tween.start()
	#######################################################################################################################
	#print(held_object_name) #object name only appears in other peers, will need to focus on how to implement for multiple concurrent objects
	#######################################################################################################################
	object_name = held_object_name
	object_transform = held_object_position

func _on_NetworkTickRate_timeout():
	if is_network_master():
		if grabbed_object != null:
			rpc_unreliable("update_state", global_transform.origin, vel, Vector2(head.rotation.x, rotation.y), flashlight.visible, animation_player.current_animation, player_name, grabbed_object.name, grabbed_object.global_transform.origin)
		else:
			rpc_unreliable("update_state", global_transform.origin, vel, Vector2(head.rotation.x, rotation.y), flashlight.visible, animation_player.current_animation, player_name, "none", "none")
	else:
		network_tick_rate.stop()
