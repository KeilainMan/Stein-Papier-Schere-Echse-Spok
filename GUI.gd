extends Control


onready var mp_name = get_node("CenterContainer/VBoxContainer/mp_name")


func _ready():
	$CenterContainer/VBoxContainer/HBoxContainer/Join.hide()
	$CenterContainer/VBoxContainer/HBoxContainer/Host.hide()
	mp_name.hide()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

func _player_connected(id):
	var names = mp_name.get_text()
	print("Player" + str(id) + "has connected")
	get_tree().change_scene("res://MPFIghtscene.tscn")
	Server.TellName(names)
	
	
func _player_disconnected(id):
	print("Player" + str(id) + "has disconnected")


func _on_Singleplayer_pressed():
	get_tree().change_scene("res://Fightscene.tscn")


func _on_Multiplayer_pressed():
	$CenterContainer/VBoxContainer/HBoxContainer/Join.show()
	$CenterContainer/VBoxContainer/HBoxContainer/Host.show()
	mp_name.show()


func _on_Host_pressed():
	pass


func _on_Join_pressed():
	Server.ConnectToServer()
