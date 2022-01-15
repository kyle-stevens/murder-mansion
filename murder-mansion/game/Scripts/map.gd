extends Spatial


var player = preload("res://Scenes/fps_player.tscn")
var _player_name = "player_"
var knife = preload("res://Scenes/knife-col.tscn")





func _ready():

	$InGameUi.visible = false
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Global.connect("instance_player", self, "_instance_player")
	
	
	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)
		$InGameUi.visible = true
		
	var knife_i = knife.instance()
	knife_i.global_transform.origin = Vector3(0,20,0)
	knife_i.name = "knife_1"
	add_child(knife_i)
	print(knife_i)


	
func _instance_player(id):
	$InGameUi.visible = true
	print("Player Created with ID: "+str(id))
	var player_instance = player.instance()
	player_instance.set_network_master(id)
	player_instance.player_name = _player_name
	player_instance.name = str(id)
	add_child(player_instance)
	player_instance.global_transform.origin = Vector3(0,15,0)
	var new_label: RichTextLabel = RichTextLabel.new()
	new_label.rect_size = Vector2(400,15)
	new_label.fit_content_height = true
	new_label.text = "\t" + player_instance.player_name #str(id)
	$InGameUi/PlayerList.add_child(new_label)
	#$InGameUi/PlayerList/Title.text = player_instance.player_name
	$InGameUi.update()
	print("Player Name is: "  + player_instance.player_name)

func _player_connected(id):
	print("Player " + str(id) + " has connected.")
	
	_instance_player(id)
	
func _player_disconnected(id):
	print("Player "+str(id)+" has disconnected")
	
	if has_node(str(id)):
		get_node(str(id)).queue_free()





func _on_PlayerName_text_changed(new_text):
	_player_name = new_text
	print(_player_name)

