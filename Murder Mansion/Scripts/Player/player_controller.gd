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
	
	#Rotation Helper Setup
	rotation_helper = $rotation_helper

func _physics_process(delta):
	if is_dead:
		gravity = 0
	process_inputs(delta)
	process_movements(delta)

func _input(event):
	if event is InputEventMouseMotion and \
	Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(
			deg2rad(event.relative.y*MOUSE_SENSITIVITY * -1)
		)
		self.rotate_y(
			deg2rad(event.relative.x*MOUSE_SENSITIVITY * -1)
		)
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -x_range, x_range)
		
		rotation_helper.rotation_degrees = camera_rot

func process_inputs(delta):
	#check if player is jumping
	if is_on_floor():
		dir = Vector3()
	
	#camera transform
	var cam_xform =  camera.get_global_transform()
	
	#set input movement
	var input_movement_vector = Vector2()
	
	#animation handling will be changed to a state machine implemented here
	
	#motion input handling
	if Input.is_action_pressed("movement_forward"):
		pass
	if Input.is_action_pressed("movement_backward"):
		pass
	if Input.is_action_pressed("movement_left"):
		pass
	if Input.is_action_pressed("movement_right"):
		pass
	
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	
	#sprinting movement - not currently implemented
	
	
	#jump input handling
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	
	#free the cursor - demo implementation, will change later
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#light toggle -will change in later implementations
	if Input.is_action_just_pressed("item_flashlight"):
		if flashlight.visible:
			flashlight.visible = false
		else:
			flashlight.visibile = true
	
	#interactable object handling
	if Input.is_action_just_pressed("item_interact"): 
		if grabbed_object == null:
			var state = get_world().direct_space_state
			var center_position = get_viewport().size / 2
			var ray_from = camera.project_ray_origin(center_position)
			var ray_to = ray_from \
			+ camera.project_ray_normal(center_position) \
			* OBJECT_GRAB_RAY_DISTANCE
			var ray_result = \
					state.intersect_ray(
						ray_from, 
						ray_to, 
						[
							self,
							$rotation_helper/gun_fire_points/grab_objects/Area
						]
					)
			if !ray_result.empty():	
				if ray_result["collider"] is RigidBody:
					grabbed_object = ray_result["collider"]
					grabbed_object.mode = RigidBody.MODE_STATIC
					grabbed_object.collision_layer = 0 #original is 0
					grabbed_object.collision_mask = 0 #original is 0
					grabbed_object.rotation = Vector3(0,-90,0)
					grabbed_object.set_visible(false)
		else:
			grabbed_object.mode = RigidBody.MODE_RIGID
			var rng = RandomNumberGenerator.new()
			var x = 0#rng.randf_range(-.5, .5)
			var y = 0.5#rng.randf_range(0, .5)
			var z = 0#rng.randf_range(0, 1)
			grabbed_object.apply_impulse(Vector3(x,y,z), 
					-camera.global_transform.basis.z.normalized()
					*OBJECT_THROW_FORCE)
			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1
			grabbed_object.damage = 5
			grabbed_object.thrower = self
			grabbed_object.set_visible(true)
			grabbed_object = null
	if grabbed_object != null:
		grabbed_object.global_transform.origin = \
				camera.global_transform.origin \
				+ (-camera.global_transform.basis.z.normalized() \
				* OBJECT_GRAB_DISTANCE)

func process_movements(delta):
	dir.y = 0
	dir = dir.normalized()	
	vel.y += delta * gravity
	var hvel = vel
	hvel.y = 0
	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(
				vel, 
				Vector3(0,1,0), 
				0.05, 
				4, 
				deg2rad(MAX_SLOPE_ANGLE)
			)
	if is_network_master():
		vel = move_and_slide(
				vel, 
				Vector3(0,1,0), 
				0.05, 
				4, 
				deg2rad(MAX_SLOPE_ANGLE)
			)
	
