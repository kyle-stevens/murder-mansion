extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var counter = 0
var animations
var animation_index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	animations = [
		"animationIdle",
		"animationLeftStrafeRun",
		"animationLeftStrafeWalk",
		"animationRightStrafeRun",
		"animationRightStrafeWalk",
		"animationRun",
		"animationWalk"
	]
	print(animations)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	counter = counter + 1
	#print(counter % 100)
	#print(animation_index)
	#print(animations[animation_index])
	$AnimationPlayer.play(animations[animation_index])
	if (counter > 100):
		counter = 0
		animation_index += 1
		print(animation_index)
		print("ITERATE ANIM")
		if animation_index >= 7:
			print("RESET ANIM")
			animation_index = 0
	
	#self.transform.origin = self.transform.origin + Vector3(0,0,0.01)
