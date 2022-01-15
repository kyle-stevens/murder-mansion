extends KinematicBody

var player_name = ""

#To Do List
#->Adding in Damage and Demo Networking
#->Code Refactoring

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()
var puppet_flashlight = true
var puppet_animation = "default"

var object_name = "none"
var object_transform


#Animation
#set up some sort of switch for this
#onready var animPlayer = get_node("player_model/femaleModel/AnimationPlayer")
onready var animPlayer = get_node("player_model/maleModel/AnimationPlayer")
#getting the fps-ness back
export(NodePath) onready var model = get_node(model) as Spatial
export(NodePath) onready var head = get_node(head) as Spatial
export(NodePath) onready var camera = get_node(camera) as Camera
export(NodePath) onready var network_tick_rate = get_node(network_tick_rate) as Timer
export(NodePath) onready var movement_tween = get_node(movement_tween) as Tween

var dead = false

#Basic Movement
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MAX_SPEED = 8#15
var vel = Vector3()
var dir = Vector3()

#Jump Movement
const JUMP_SPEED = 9
var gravity = -24.8

#Sprint Movement
var is_sprinting = false
var MAX_SPRINT_SPEED = 20
var SPRINT_ACCEL = 18

#Flashlight
var flashlight

#Camera
#var camera
export var x_range = 70

#Grabbing RigidBodys
var grabbed_object = null
export var OBJECT_THROW_FORCE = 2#120 #change to const upon balancing
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
	
#	var ParentUI = get_tree().get_root().get_node("Map/InGameUi/PlayerList")
#	var new_label: RichTextLabel = RichTextLabel.new()
#	new_label.rect_size = Vector2(400,15)
#	new_label.fit_content_height = true
#	new_label.text = player_name
#	ParentUI.add_child(new_label)
#	ParentUI.update()
	
	
	camera.current = is_network_master()
	model.visible = !is_network_master()
	
	
	#Camera
	#camera = $rotation_helper/player_camera
	
	#Rotation Helper
	rotation_helper = $rotation_helper
	
	#Flashlight
	flashlight = $rotation_helper/player_flashlight
	
	#UI
	reticle = $player_hud/Reticle
	reticle.set_position(get_viewport().size / 2)
	#Change Var for Color Shift
	reticle = $player_hud/Reticle/ColorRect
	
	#Grabbing Objects
	object_detection = $rotation_helper/gun_fire_points
	object_detection_collision = \
			$rotation_helper/gun_fire_points/grab_objects/Area/CollisionShape
			
	#Set initial Animation
	animPlayer.play("default")
	
	if true:
		#Set Area to Grab Distance
		object_detection.translation = \
				Vector3(0,0,OBJECT_GRAB_RAY_DISTANCE / 2 * -1)
		object_detection_collision.get_shape().set_extents(
				Vector3(.05,.05,OBJECT_GRAB_RAY_DISTANCE / 2)
				)
				
	#Initial Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if dead:
		gravity = 0
	
	process_inputs(delta)
	process_movement(delta)
	
	#print(object_name)
	#print(grabbed_object)
	if object_name != "none": #change to a check if the value has changed
		var node_Test = get_tree().get_root().get_node(object_name)
		print(node_Test)
		


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
					animPlayer.play("leftstrafe")
				elif right:
					animPlayer.play("rightstrafe")
				else:	
					animPlayer.play("walk")
			elif backward and is_on_floor():
				if left:
					animPlayer.play_backwards("rightstrafe")
				elif right:
					animPlayer.play_backwards("leftstrafe")
				else:	
					animPlayer.play_backwards("walk")
			elif left and is_on_floor():
				animPlayer.play("leftstrafe")
			elif right and is_on_floor():
				animPlayer.play("rightstrafe")
			
			
			
			if abs(vel.x) < 1 and abs(vel.y) < 1 and abs(vel.z) < 1 and is_on_floor():
				animPlayer.play("default")
			if not is_on_floor():
				animPlayer.play("jump")
	#		if Input.is_action_pressed("movement_forward") and is_on_floor():
	#			input_movement_vector.y += 1
	#			if Input.is_action_pressed("movement_left"):
	#				input_movement_vector.x -= 1
	#				animPlayer.play("leftstrafe")
	#			elif Input.is_action_pressed("movement_right"):
	#				input_movement_vector.x += 1
	#				animPlayer.play("rightstrafe")
	#			else:
	#				animPlayer.play("walk")
	#		if Input.is_action_pressed("movement_backward") and is_on_floor():
	#			input_movement_vector.y -= 1
	#			if Input.is_action_pressed("movement_left"):
	#				input_movement_vector.x -= 1
	#				animPlayer.play_backwards("rightstrafe")
	#			elif Input.is_action_pressed("movement_right"):
	#				input_movement_vector.x += 1
	#				animPlayer.play_backwards("leftstrafe")
	#			else:
	#				animPlayer.play_backwards("walk")
	#		if Input.is_action_pressed("movement_left") and is_on_floor():
	#			input_movement_vector.x -= 1
	#			if Input.is_action_pressed("movement_forward"):
	#				input_movement_vector.y += 1
	#				animPlayer.play("leftstrafe")
	#			elif Input.is_action_pressed("movement_backwards"):
	#				input_movement_vector.y -= 1
	#				animPlayer.play_backwards("rightstrafe")
	#			else:
	#				animPlayer.play("leftstrafe")
	#		if Input.is_action_pressed("movement_right") and is_on_floor():
	#			input_movement_vector.x += 1
	#			if Input.is_action_pressed("movement_forward"):
	#				input_movement_vector.y += 1
	#				animPlayer.play("righttstrafe")
	#			elif Input.is_action_pressed("movement_backwards"):
	#				input_movement_vector.y -= 1
	#				animPlayer.play_backwards("leftstrafe")
	#			else:
	#				animPlayer.play("rightstrafe")
			input_movement_vector = input_movement_vector.normalized()
			
			dir += -cam_xform.basis.z * input_movement_vector.y
			dir += cam_xform.basis.x * input_movement_vector.x
			
			#Jump Movement
			if is_on_floor():
				if Input.is_action_just_pressed("movement_jump"):
					vel.y = JUMP_SPEED
					animPlayer.play("jump")
			
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
				#is_sprinting = true
				pass
				#sprinting removed for the moment
			else:
				is_sprinting = false
				
			#Grabbing RigidBody's
			if Input.is_action_just_pressed("fire_grenade"): 
				# and current_weapon == "UNARMED": #For Use in True FPS
				if grabbed_object == null:
					var state = get_world().direct_space_state
					var center_position = get_viewport().size / 2
					var ray_from = camera.project_ray_origin(center_position) #camera is behind head now, causing collision issues
					#var ray_from = objectToThrowVar.project_ray_origin(center_position)
					#same as above, camera is behind head
					var ray_to = ray_from \
					+ camera.project_ray_normal(center_position) \
					* OBJECT_GRAB_RAY_DISTANCE
	#				var ray_to = ray_from \
	#				+ objectToThrowVar.project_ray_normal(center_position) \
	#				* OBJECT_GRAB_RAY_DISTANCE
					
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
							#print(grabbed_object.name)
							#Just for Size Purposes with test object
							#grabbed_object.scale = grabbed_object.scale * .5
							#front facing in blender is also how the object is 
							#oriented at 0,0,0 rotation
							grabbed_object.rotation = Vector3(0,-90,0)
							#grabbed_object.set_visible(false)
							#Setup logic for holding object in hand here
							
				else:
					grabbed_object.mode = RigidBody.MODE_RIGID
					var rng = RandomNumberGenerator.new()
					#rng.randomize()
					var x = 0#rng.randf_range(-.5, .5)
					var y = 0.5#rng.randf_range(0, .5)
					var z = 0#rng.randf_range(0, 1)
					grabbed_object.apply_impulse(Vector3(x,y,z), 
					#make these slightly random for interesting play
							-camera.global_transform.basis.z.normalized()
							*OBJECT_THROW_FORCE)#/grabbed_object.weightOfObject)
					grabbed_object.collision_layer = 1
					grabbed_object.collision_mask = 1
					#grabbed_object.thrown = true #Object has been thrown
					grabbed_object.damage = 5
					grabbed_object.thrower = self
					#Just for Size Purposes with test object
					#grabbed_object.scale = grabbed_object.scale * 2
					grabbed_object.set_visible(true)
					#print(grabbed_object.thrown)
					grabbed_object = null
					#Setup logic for removing object in hand here
			if grabbed_object != null:
				grabbed_object.global_transform.origin = \
						camera.global_transform.origin \
						+ (-camera.global_transform.basis.z.normalized() \
						* (OBJECT_GRAB_DISTANCE / 3))


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()	
	vel.y += delta * gravity
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
		animPlayer.play(puppet_animation)
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

#Considering Highlighting Objects or Highlighting/Changing HUD Reticle
func _on_Area_body_entered(body):
	#Highlight RigidBody
	if body is RigidBody:
		var CSGSPHERE : Node = body.get_node("CSGSphere")
		#CSGSPHERE.material_override = \
		#load("res://Shaders_and_Materials/plain_white_material_outline.tres")
		
		#print(CSGSPHERE)
		#reticle.color = Color(0,1,0,1)
	pass


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
		animPlayer.play("death")
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
	print(held_object_name) #object name only appears in other peers, will need to focus on how to implement for multiple concurrent objects
	#######################################################################################################################
	object_name = held_object_name
	object_transform = held_object_position
	
	
	



func _on_NetworkTickRate_timeout():
	if is_network_master():
		if grabbed_object != null:
			rpc_unreliable("update_state", global_transform.origin, vel, Vector2(head.rotation.x, rotation.y), flashlight.visible, animPlayer.current_animation, player_name, grabbed_object.name, grabbed_object.global_transform.origin)
		else:
			rpc_unreliable("update_state", global_transform.origin, vel, Vector2(head.rotation.x, rotation.y), flashlight.visible, animPlayer.current_animation, player_name, "none", "none")
	else:
		network_tick_rate.stop()
