###############################################################################
# Network Script ##############################################################
###############################################################################

extends Node

###NETWORK CONSTANTS###########################################################

const DEFAULT_PORT= 28960
const MAX_CLIENTS = 5

###NETWORK VARIABLES###########################################################

var server = null
var client = null

# Default IP Address
var ip_address = "127.0.0.1"

###############################################################################
# Ready Function - Preps basic connections for network functionality and ######
# Network Functions ###########################################################
###############################################################################
func _ready():
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	get_tree().connect("connection_failed",self,"_connection_failed")
	get_tree().connect("network_peer_connected",self,"_player_connected")

###############################################################################
# Create Server Function - Implements UPNP when applicable, otherwise creates #
# a server at home IP address #################################################
###############################################################################
func create_server():
	#upnp cannot detect a router .... this is an issue
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(28960)
	
	print("UPNP Device Count: ", upnp.get_device_count())
	print("UPNP Device External Address: ", upnp.query_external_address())
	print("UPNP Device Gateway: ", upnp.get_gateway())
	
	
	print("CREATING SERVER..." + ip_address)
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	get_tree().set_network_peer(server)
	upnp.delete_port_mapping(28960)
	
###############################################################################
# Join Server Function - Implements instancing of new player and adds network #
# peer to the current server ##################################################
###############################################################################
func join_server():
	print("JOINING SERVER..." + ip_address)
	
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,DEFAULT_PORT)
	get_tree().set_network_peer(client)

###############################################################################

###############################################################################
func _connected_to_server():
	print("CONNECTED SUCCESSFULLY")

###############################################################################

###############################################################################
func _server_disconnected():
	print("DISCONNECTED FROM SERVER")
	reset_network_connection()

###############################################################################

###############################################################################
func _connection_failed():
	print("CONNECTION ATTEMPT FAILED")
	reset_network_connection()

###############################################################################

###############################################################################
func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer = null

###############################################################################

###############################################################################
func _player_connected(id):
	print("PEER " + str(id) + " HAS CONNECTED")
