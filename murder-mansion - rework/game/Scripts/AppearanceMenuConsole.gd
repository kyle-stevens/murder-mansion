extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var at_console = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	if at_console and Input.is_action_just_pressed("appearance_menu"):
		add_child(load("res://Scenes/AppearanceMenu.tscn").instance())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_AppearanceMenuConsole_body_entered(body):
	if body is KinematicBody and body.is_network_master():
		at_console = true
		print(at_console)




func _on_AppearanceMenuConsole_body_exited(body):
	if body is KinematicBody and body.is_network_master():
		at_console = false
		print(at_console)
