extends RigidBody

export var weightOfObject = 1.0

var thrown = true
var thrower = null
export var damage = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	thrown = true
	$CSGSphere.material_override = \
		load("res://Shaders_and_Materials/plain_white_material_outline.tres")
	
func _physics_process(delta):
	if true :
		#print("Rigid Object fell on floor")
		thrown = false
		#need to add area collisions to all floor/wall/ceiling type objects to 
		#reset thrown to false
