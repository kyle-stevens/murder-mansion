###############################################################################
# AppearanceMenuConsole Script ################################################
###############################################################################

extends Area

###VARIABLES###################################################################
var at_console = false

# Ready Function - Does Nothing for MenuConsole
func _ready():
	pass

# Maintain Checks for if the player is near the console to interact with it
func _process(delta):
	if at_console and Input.is_action_just_pressed("interact"):
		add_child(load("res://Scenes/AppearanceMenu.tscn").instance())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Change the at_console variable to 'true' if the player model has entered the
# detection area
func _on_AppearanceMenuConsole_body_entered(body):
	if body is KinematicBody and body.is_network_master():
		at_console = true
		print(at_console)
		body.get_node("UI/popupMesg").text = "press 'E' to interact"

# Change the at_console variable to 'false' if the player model has entered the
# detection area
func _on_AppearanceMenuConsole_body_exited(body):
	if body is KinematicBody and body.is_network_master():
		at_console = false
		print(at_console)
		body.get_node("UI/popupMesg").text = ""
