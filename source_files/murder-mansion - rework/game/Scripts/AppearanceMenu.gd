###############################################################################
# AppearanceMenu Script #######################################################
###############################################################################

extends Control

# Ready Function - Does not do anything for the menu
func _ready():
	pass

func _process(delta):
	for color in Global.colors:
		if Global.colors[color] == 1:
			get_node("Panel/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/" + color).disabled = true
		else:
			get_node("Panel/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/" + color).disabled = false

###HAT BUTTON SIGNAL FUNCTIONS#################################################
func _on_Crown_pressed():
	PlayerVariables.player_hat = "res://Assets/hats/crown.obj"

func _on_DemonCrown_pressed():
	PlayerVariables.player_hat = "res://Assets/hats/demonCrown.obj"

func _on_PiratesHat_pressed():
	PlayerVariables.player_hat = "res://Assets/hats/piratesHat.obj"

func _on_TopHat_pressed():
	PlayerVariables.player_hat = "res://Assets/hats/topHat.obj"

func _on_VikingHat_pressed():
	PlayerVariables.player_hat = "res://Assets/hats/vikingHat.obj"

###COLOR BUTTON FUNCTIONS######################################################
func _on_White_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/White.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["White"] = 1

func _on_Black_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Black.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Black"] = 1

func _on_Green_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Green.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Green"] = 1

func _on_Purple_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Purple.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Purple"] = 1

func _on_Blue_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Blue.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Blue"] = 1

func _on_Red_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Red.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Red"] = 1

func _on_Yellow_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Yellow.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Yellow"] = 1

func _on_Brown_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Brown.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Brown"] = 1

func _on_Teal_pressed():
	PlayerVariables.player_color = "res://Assets/player_materials/Teal.tres"
	for color in Global.colors:
		Global.colors[color] = 0
	Global.colors["Teal"] = 1

###TERTIARY FUNCTIONS##########################################################

# Recapture mouse and close appearance menu
func _on_Exit_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.queue_free()
