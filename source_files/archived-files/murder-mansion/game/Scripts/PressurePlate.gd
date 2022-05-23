extends Area
var active = false
func _ready():
	pass # Replace with function body.


func _on_PressurePlate_body_entered(body):
	if body is RigidBody or body is KinematicBody:
		print("PressurePlate")
		active = not active
		print(active)
		queue_free()
		#attach to other objects/nodes that will be activated by the 
		#plate or not
		#Also need to let players hit it
