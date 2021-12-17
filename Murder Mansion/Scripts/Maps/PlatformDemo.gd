extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player1pos = $player1pos
onready var player2pos = $player2pos

# Called when the node enters the scene tree for the first time.
func _ready():
	#Attempt number 2 at networking, setup networking in player node
#	var player1 = preload("res://Scenes/Players/player_controller.tscn")
#	player1.set_name(str(player1.netId))
#	player1.set_network_master(player1.netId)
#	add_child(player1)
#	return
#
	var player1 = preload("res://Scenes/Players/player_controller.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	add_child(player1)
	
	print(player1.name)
	print(player1.netId)

	var player2 = preload("res://Scenes/Players/player_controller.tscn").instance()
	player2.set_name(str(Globals.player2id))
	player2.set_network_master(Globals.player2id)
	player2.global_transform = player2pos.global_transform
	add_child(player2)
	print(player2.name)
	print(player2.netId)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
