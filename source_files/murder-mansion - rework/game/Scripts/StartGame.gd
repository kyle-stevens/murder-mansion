extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var at_console = false
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if at_console and Input.is_action_just_pressed("interact"):
		Global.emit_signal("start_game")
		pass
		

func _on_StartGame_body_entered(body):
	if body is KinematicBody and body.is_network_master():
		at_console = true
		print(at_console)
		body.get_node("UI/popupMesg").text = "press 'E' to start game"
		

func _on_StartGame_body_exited(body):
	if body is KinematicBody and body.is_network_master():
		at_console = false
		print(at_console)
		body.get_node("UI/popupMesg").text = ""
		
