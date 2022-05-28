extends Node

signal instance_player(id)
signal toggle_network_setup(toggle)

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_TAB:
			#get_tree().quit()
			pass
