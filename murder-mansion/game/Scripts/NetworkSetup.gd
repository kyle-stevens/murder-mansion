extends Control

func _on_IpAddress_text_changed(new_text):
	Network.ip_address = new_text


func _on_Host_pressed():
	Network.create_server()
	hide()


func _on_Join_pressed():
	Network.join_server()
	hide()
