extends Node


var network = NetworkedMultiplayerENet.new()
#var ip = "212.227.155.184"
#var ip = "127.0.0.1"
#var ip_pc: String = "192.168.2.171"
#var port = 3434


signal connection_failed()
signal connection_succeded()

func _ready():
	pass


################################################################################
## SETUP ##


func ConnectToServer(ip: String, port: int) -> void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("ip: " + str(ip) + ", Port: " + str(port))
	
	network.connect("connection_failed", self, "_on_ConnectionFailed")
	network.connect("connection_succeeded", self, "_on_ConnectionSucceeded")
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")


func _on_ConnectionFailed() -> void:
	print("Failed to connect")


func _on_ConnectionSucceeded() -> void:
	print("Connection to the server successful!")



func _player_connected(id: int) -> void:
	if id == 1:
		print("Server connected")
	else:
		print("Player " + str(id) + " has connected to the server")

	


func _player_disconnected(id: int) -> void:
	print("Player" + str(id) + "has disconnected")


func _connected_to_server() -> void:
	print("You are now connected to the server!")
	

#func GetEnemyChoice(requester: int) -> void:
#	rpc_id(1, "GatherEnemyChoice", requester)
#
#
#remote func ReturnEnemyChoice(enemychoice, requester) -> void:
#	instance_from_id(requester).SetEnemyChoice(enemychoice)
#
#
#func SendPlayerChoice(player_choice) -> void:
#	rpc_id(1, "ReceivePlayerChoice", player_choice)
#
#
#remote func ReturnEveryoneIsReady() -> void:
#	enemy_ready = true


################################################################################
## UPON CONNECTION ##


func send_player_name(player_name) -> void:
	rpc_id(1, "receive_player_name", player_name)


func send_player_requester(requester_id: int) -> void:
	rpc_id(1, "receive_player_requester_id", requester_id)


################################################################################
## REQUESTS FROM SERVER ##


remote func set_both_player_names(player_name: String, enemy_name: String, requester_id: int) -> void:
	instance_from_id(requester_id).set_both_player_names(player_name, enemy_name)


remote func start_game(requester_id: int) -> void:
	instance_from_id(requester_id).start_game()


remote func get_current_choice(requester_id: int) -> int:
	var choice: int = instance_from_id(requester_id).get_current_choice()
	print("SERVER received player choice: ", choice)
	return choice


remote func set_enemy_choice(enemy_choice: int, requester_id: int) -> void:
	instance_from_id(requester_id).set_enemy_choice(enemy_choice)
################################################################################
## SEND TO SERVER ##


func send_player_ready_notice() -> void:
	rpc_id(1, "notice_player_is_ready")


func push_player_choice(choice: int) -> void:
	rpc_id(1, "collect_player_choice", choice)


func send_game_finished_notice() -> void:
	rpc_id(1, "notice_game_is_finished")
#
#func CheckTwoPlayers() -> void:
#	rpc_id(1, "TwoPlayerCheck")
#
#
#remote func ReturnTwoPlayers() -> void:
#	two_players = true
#
#
#func PlayerReadyGameStart() -> void:
#	rpc_id(1, "PlayerReadyCheck")
#
#
#remote func GameReady() -> void:
#	gameready = true
#
#
#func GetPlayerNames(requester) -> void:
#	rpc_id(1, "SendPlayerNames", requester)
#	print("getting Playernames")
#
#
#remote func ReturnNames(name_player, name_enemy, requester) -> void:
#	print("received " + name_player + name_enemy)
#	instance_from_id(requester).setNames(name_player, name_enemy)

