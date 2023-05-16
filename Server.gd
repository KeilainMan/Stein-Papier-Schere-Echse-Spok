extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "212.227.155.184"
#var ip = "127.0.0.1"
var port = 1909

var enemy_ready = false
var two_players = false
var gameready = false
var player_name := ""
var enemy_name := ""

signal names_received

func _ready():
	pass
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("ip: " + str(ip) + ", Port: " + str(port))
	print(network)
	network.connect("connection_failed", self, "_onConnectionFailed")
	network.connect("connection_succeeded", self, "_onConnectionSucceeded")
	
func _onConnectionFailed():
	print("Failed to connect")
	
	
func _onConnectionSucceeded():
	print("Succesfully connected")


func GetEnemyChoice(requester):
	rpc_id(1, "GatherEnemyChoice", requester)
	
remote func ReturnEnemyChoice(enemychoice, requester):
	instance_from_id(requester).SetEnemyChoice(enemychoice)

func SendPlayerChoice(player_choice):
	rpc_id(1, "ReceivePlayerChoice", player_choice)


remote func ReturnEveryoneIsReady():
	enemy_ready = true
	
func TellName(names):
	rpc_id(1, "ReceivePlayerName", names)

	
func CheckTwoPlayers():
	rpc_id(1, "TwoPlayerCheck")
	
remote func ReturnTwoPlayers():
	two_players = true
	
func PlayerReadyGameStart():
	rpc_id(1, "PlayerReadyCheck")
	
remote func GameReady():
	gameready = true

func GetPlayerNames(requester):
	rpc_id(1, "SendPlayerNames", requester)
	print("getting Playernames")
	
remote func ReturnNames(name_player, name_enemy, requester):
	print("received " + name_player + name_enemy)
	instance_from_id(requester).setNames(name_player, name_enemy)
