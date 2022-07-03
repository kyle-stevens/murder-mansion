extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var knife = get_node("knife-col2")
var knife_init_pos_Y
var going_up = true
# Called when the node enters the scene tree for the first time.
func _ready():
	knife_init_pos_Y = knife.global_transform.origin.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	knife.rotate_y(0.01)
	if abs(knife.global_transform.origin.y - knife_init_pos_Y) > 0.25:
		going_up = not going_up
		
	if going_up: 
		knife.global_transform.origin.y += 0.005
	else:
		knife.global_transform.origin.y -= 0.005


func _on_Area_body_entered(body):
	if body.killer:
		knife.visible = false
		var timer = Timer.new()
		timer.connect("timeout", self, "_on_Timer_Timeout")
		timer.set_wait_time(2)
		add_child(timer)
		timer.start()
	else:
		pass
	
func _on_Timer_Timeout():
	knife.visible = true
