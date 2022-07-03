extends Spatial

onready var player1pos = $player1pos
onready var player2pos = $player2pos

func _ready():
	var player1 = preload("res://Scenes/fps_player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	add_child(player1)
	return
	var player2 = preload("res://Scenes/fps_player.tscn").instance()
	player2.set_name(str(get_tree().get_network_unique_id()))
	player2.set_network_master(get_tree().get_network_unique_id())
	player2.global_transform = player2pos.global_transform

	add_child(player2)
