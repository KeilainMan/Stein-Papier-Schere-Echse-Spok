extends Control



onready var mp_name_edit: LineEdit = $CenterContainer/VBoxContainer/MPNameEdit
onready var host_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/HostButton
onready var join_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/JoinButton

var singleplayer_scene_path: String = "res://Singleplayer/SinglePlayer.tscn"
var multiplayer_scene_path: String = "res://Multiplayer/Multiplayer.tscn"




func _ready() -> void:
	join_button.hide()
	host_button.hide()
	mp_name_edit.hide()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")


func _player_connected(id: int) -> void:
	var names: String = mp_name_edit.get_text()
	print("Player" + str(id) + "has connected")
	get_tree().change_scene(multiplayer_scene_path)
	Server.TellName(names)


func _player_disconnected(id: int) -> void:
	print("Player" + str(id) + "has disconnected")


func _on_Singleplayer_pressed() -> void:
	get_tree().change_scene(singleplayer_scene_path)


func _on_Multiplayer_pressed() -> void:
	join_button.show()
	host_button.show()
	mp_name_edit.show()


func _on_Host_pressed() -> void:
	pass


func _on_Join_pressed() -> void:
	Server.ConnectToServer()
