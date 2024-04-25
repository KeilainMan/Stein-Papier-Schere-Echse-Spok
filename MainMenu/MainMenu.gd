extends Control


export var debug_mode_mp: bool = false
export var debug_mode_sp: bool = false

onready var singleplayer_button: Button = $CenterContainer/VBoxContainer/SingleplayerButton
onready var multiplayer_button: Button = $CenterContainer/VBoxContainer/MultiplayerButton
onready var mp_name_edit: LineEdit = $CenterContainer/VBoxContainer/MPNameEdit
onready var host_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/HostButton
onready var join_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/JoinButton
onready var ip_button: OptionButton = $CenterContainer/VBoxContainer/IPButton
onready var ip_edit: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer2/IPEdit
onready var port_edit: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer2/PortEdit


var singleplayer_scene_path: String = "res://Singleplayer/SinglePlayer.tscn"
var multiplayer_scene_path: String = "res://Multiplayer/Multiplayer.tscn"


const IP_LOCALHOST: String = "127.0.0.1"
const IP_PC: String = ""
const PORT: int = 3434

func _ready() -> void:
	hide_mp_ui()

	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	
	if debug_mode_mp:
		multiplayer_button.emit_signal("pressed")
		join_button.emit_signal("pressed")


func hide_mp_ui() -> void:
	join_button.hide()
	host_button.hide()
	mp_name_edit.hide()
	ip_button.hide()
	ip_edit.hide()
	port_edit.hide()

################################################################################
## SINGELPLAYER ##


func _on_Singleplayer_pressed() -> void:
	get_tree().change_scene(singleplayer_scene_path)


################################################################################
## MULTIPLAYER ##


func _on_connected_to_server() -> void:
	print("connected")
	var player_name: String = mp_name_edit.get_text()
	Server.send_player_name(player_name)
	get_tree().change_scene(multiplayer_scene_path)


func _on_Multiplayer_pressed() -> void:
	show_mp_ui()


func show_mp_ui() -> void:
	join_button.show()
#	host_button.show()
	mp_name_edit.show()
#	ip_button.show()
	ip_edit.show()
	port_edit.show()


func _on_Host_pressed() -> void:
	pass


func _on_Join_pressed() -> void:
	##debug old##
#	var ip_selection: int = ip_button.selected
#	var ip: String 
#
#	match ip_selection:
#		0:
#			ip = IP_LOCALHOST
#		1:
#			ip = IP_PC
	##
	
	var ip_adress: String = ip_edit.text
	var port: int = int(port_edit.text)
	var player_name: String = mp_name_edit.text 

	if debug_mode_mp:
		ip_adress = IP_LOCALHOST
		port = PORT
		mp_name_edit.text = "Dummy1"

	if port == 0 or ip_adress == "":
		ip_adress = IP_LOCALHOST
		port = PORT
	if port == 0 or ip_adress == "" or mp_name_edit.text == "":
		print("No valid IP, Port or PlayerName!")
		return
	
	Server.ConnectToServer(ip_adress, port)

