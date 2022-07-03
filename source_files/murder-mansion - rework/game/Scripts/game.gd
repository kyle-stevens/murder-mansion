extends Spatial

var player = preload("res://Scenes/player_instance.tscn")
var _player_name = "player_"
signal start_game

func _ready():
	
	#expanding spawn points via code since its easier than doing by hand
	for spawn_point in $PlayerPoints.get_children():
		spawn_point.global_transform.origin = Vector3(spawn_point.global_transform.origin.x*3, spawn_point.global_transform.origin.y, spawn_point.global_transform.origin.z*3)
	
	
	#not working
	var upnp = UPNP.new()
	upnp.discover(2000,2,"InternetGatewayDevice")
	print(upnp)
	print(upnp.query_external_address())
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Global.connect("instance_player", self, "_instance_player")
	Global.connect("start_game",self,"_start_game")
	
	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)
	

func _physics_process(delta):
	pass
	
	
#need to trigger this for all players on map code change
func _start_game():
	if Global.map_code != 0 and not Global.game_started:
		#Get root node of game scene
		var root_node_current = get_tree().get_current_scene()
		
		print("WE CHANGE THE WORLD NOW") #reset global.map_id after this to prevent changes
		if ($Map/AppearanceMenuConsole):
			$Map/AppearanceMenuConsole.queue_free() #seems that triggering signal twice is causing issues, restructure needed in player instance to fix this
		if ($Map/StartGame):
			$Map/StartGame.queue_free()
		if ($Map/Roof_Slats):
			$Map/Roof_Slats.queue_free()
		Global.map_code = 0
		Global.game_started = true
		

func _instance_player(id):

	
	print("Player Created with ID: "+str(id))
	var player_instance = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	$Players.add_child(player_instance)
	var ActivePlayers = $Players.get_child_count() - 1
	player_instance.global_transform.origin = $PlayerPoints.get_children()[ActivePlayers].global_transform.origin
		
	#player_instance.global_transform.origin = Vector3(0,5,5)
	

func _player_connected(id):
	print("Player " + str(id) + " has connected.")
	
	_instance_player(id)
	
func _player_disconnected(id):
	print("Player "+str(id)+" has disconnected")
	
	if has_node("Players/" + str(id)):
		get_node("Players/" + str(id)).queue_free()

func _on_PlayerName_text_changed(new_text):
	_player_name = new_text
	PlayerVariables.player_name = new_text
	print(_player_name)

func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		PlayerVariables.player_model = "Male"
	else:
		PlayerVariables.player_model = "Female"
