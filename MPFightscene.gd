extends Node


var scissors := 1
var stone := 2
var paper := 3
var lizard := 4
var spock := 5

onready var a_player_1 = get_node("AnimationPlayer")
onready var a_player_2 = get_node("AnimationPlayer2")

var enemy_choice
var player_choice
var player_win_counter :=0
var enemy_loose_counter :=0
var enemy_win_counter :=0
var player_loose_counter :=0

signal stalemate
signal player_wins
signal enemy_wins
signal end_game
signal names_received

func _ready():
	hide_ui()
	$player_selection.hide()
	$HBoxContainer/vs.hide()
	$Start_game.hide()
	connect("player_wins", self, "on_player_wins")
	connect("enemy_wins", self, "on_enemy_wins")
	connect("stalemate", self, "on_stalemate")
	connect("end_game", self, "on_end_game")
	$waitingforPlayerTimer.start()
	connect("names_received", self, "setNames")

func _on_waitingforPlayerTimer_timeout():
	if Server.two_players == false:
		Server.CheckTwoPlayers()
	else:
		get_player_names()
		Server.two_players = false
		$Waiting_for_Player.hide()
		$waitingforPlayerTimer.stop()
		$Start_game.show()
		$HBoxContainer/vs.show()
		print("name1: " + Server.player_name)
		print("name2: " + Server.enemy_name)
		
		
func get_player_names():
	Server.GetPlayerNames(get_instance_id())
		
func setNames(player, enemy):
	$HBoxContainer/Player_1_Name.text = player
	$HBoxContainer/Player_2_Name.text = enemy
	
	
func hide_ui():
	$Hbox/Cntr1/LinkeFaust.hide()
	$Hbox/Cntr2/RechteFaust.hide()
	$Hbox/Cntr2/ESchere.hide()
	$Hbox/Cntr2/EStein.hide()
	$Hbox/Cntr2/EPapier.hide()
	$Hbox/Cntr2/EEchse.hide()
	$Hbox/Cntr2/ESpok.hide()
	$Hbox/Cntr1/Schere.hide()
	$Hbox/Cntr1/Stein.hide()
	$Hbox/Cntr1/Papier.hide()
	$Hbox/Cntr1/Echse.hide()
	$Hbox/Cntr1/Spok.hide()
	$Hbox/Cntr1/Fragezeichen1.hide()
	$Hbox/Cntr2/Fragezeichen2.hide()
	$Winner.hide()
	$Winner2.hide()
	$NextRound.hide()
	$GameReadyLabel.hide()
	

	
func winner_determination():
	if player_choice == 1:
		if enemy_choice ==1:
			emit_signal("stalemate") 
			print("Stalemate")
		if enemy_choice == 2 or enemy_choice == 5:
			emit_signal("enemy_wins")
			print("enemy wins")
		if enemy_choice == 3 or enemy_choice == 4:
			emit_signal("player_wins")
			print("player wins")
	if player_choice == 2:
		if enemy_choice == 1 or enemy_choice == 4:
			emit_signal("player_wins")
		if enemy_choice == 2:
			emit_signal("stalemate")
		if enemy_choice == 3 or enemy_choice == 5:
			emit_signal("enemy_wins")
	if player_choice == 3 :
		if enemy_choice == 2 or enemy_choice == 5:
			emit_signal("player_wins")
		if enemy_choice == 1 or enemy_choice == 4:
			emit_signal("enemy_wins")
		if enemy_choice == 3:
			emit_signal("stalemate")
	if player_choice == 4:
		if enemy_choice == 3 or enemy_choice == 5:
			emit_signal("player_wins")
		if enemy_choice == 1 or enemy_choice == 2:
			emit_signal("enemy_wins")
		if enemy_choice == 4:
			emit_signal("stalemate")
	if player_choice == 5:
		if enemy_choice == 1 or enemy_choice == 2:
			emit_signal("player_wins")
		if enemy_choice == 3 or enemy_choice == 4:
			emit_signal("enemy_wins")
		if enemy_choice == 5:
			emit_signal("stalemate")
			



func _on_ASchere_pressed():
	player_choice = 1
	start_after_selection()

func _on_AStein_pressed():
	player_choice = 2
	start_after_selection()

func _on_APapier_pressed():
	player_choice = 3
	start_after_selection()

func _on_AEchse_pressed():
	player_choice = 4
	start_after_selection()

func _on_ASpok_pressed():
	player_choice = 5
	start_after_selection()

func start_after_selection():
	$player_selection.hide()
	Server.SendPlayerChoice(player_choice)
	$Checktimer.start()
	#Timeranimation
	$Hbox/Cntr1/Fragezeichen1.show()
	$Hbox/Cntr2/Fragezeichen2.show()
	
func _on_Checktimer_timeout():
	if Server.enemy_ready == true:
			call_enemy_choice()
			$Revealtimer.start()
			print("ready")
			$Checktimer.stop()
			Server.enemy_ready = false

	
func _on_Revealtimer_timeout():
	$Hbox/Cntr1/Fragezeichen1.hide()
	$Hbox/Cntr2/Fragezeichen2.hide()
	$Hbox/Cntr1/LinkeFaust.show()
	$Hbox/Cntr2/RechteFaust.show()
	a_player_1.play("Schüttelbewegung Links")
	a_player_2.play("Schüttelbewegung Rechts")
	yield(a_player_1, "animation_finished")
	show_player_selection()
	yield(a_player_2, "animation_finished")
	show_enemy_choice()
	
func show_player_selection():
	$Hbox/Cntr1/LinkeFaust.hide()
	if player_choice == 1:
		$Hbox/Cntr1/Schere.show()
		#animation rammen
	if player_choice == 2:
		$Hbox/Cntr1/Stein.show()
		#animation rammen
	if player_choice == 3:
		$Hbox/Cntr1/Papier.show()
		#animation rammen
	if player_choice == 4:
		$Hbox/Cntr1/Echse.show()
		#animation rammen
	if player_choice == 5:
		$Hbox/Cntr1/Spok.show()
		#animation rammen
		
func show_enemy_choice():
	$Hbox/Cntr2/RechteFaust.hide()
	if enemy_choice == 1:
		$Hbox/Cntr2/ESchere.show()
		#animation rammen
		winner_determination()
	if enemy_choice == 2:
		$Hbox/Cntr2/EStein.show()
		#animation rammen
		winner_determination()
	if enemy_choice == 3:
		$Hbox/Cntr2/EPapier.show()
		#animation rammen
		winner_determination()
	if enemy_choice == 4:
		$Hbox/Cntr2/EEchse.show()
		#animation rammen
		winner_determination()
	if enemy_choice == 5:
		$Hbox/Cntr2/ESpok.show()
		#animation rammen
		winner_determination()

func on_player_wins():
	yield(get_tree().create_timer(1), "timeout")
	add_loose_enemy()
	add_win_player()

	
	
func add_win_player():
	var position = get_node("Control/1a/2a/Playerpoints")
	var point = TextureRect.new()
	point.set_texture(load("res://won_point.png"))
	position.add_child(point, player_win_counter)
	player_win_counter += 1
	emit_signal("end_game")
	
func add_loose_enemy():
	var position = get_node("Control/1a/2b/Enemypoints")
	var point = TextureRect.new()
	point.set_texture(load("res://lost_point.png"))
	position.add_child(point, enemy_loose_counter)
	enemy_loose_counter += 1
	
func on_enemy_wins():
	yield(get_tree().create_timer(1), "timeout")
	add_player_loose()
	add_enemy_win()

	

func add_player_loose():
	var position = get_node("Control/1a/2a/Playerpoints")
	var point = TextureRect.new()
	point.set_texture(load("res://lost_point.png"))
	position.add_child(point, player_loose_counter)
	player_loose_counter += 1
	
func add_enemy_win():
	var position = get_node("Control/1a/2b/Enemypoints")
	var point = TextureRect.new()
	point.set_texture(load("res://won_point.png"))
	position.add_child(point, enemy_win_counter)
	enemy_win_counter += 1
	emit_signal("end_game")
	
func on_stalemate():
	$NextRound.show()


func _on_Start_game_pressed():
	Server.PlayerReadyGameStart()
	$GameReadyTimer.start()
	$GameReadyLabel.show()


func _on_GameReadyTimer_timeout():
	if Server.gameready == true:
		start_game()
		Server.gameready = false
		$GameReadyTimer.stop()
		$GameReadyLabel.hide()
	
func start_game():
	$player_selection.show()
	hide_ui()
	$Start_game.hide()
	$NextRound.hide()
	
	
func call_enemy_choice():
	Server.GetEnemyChoice(get_instance_id())
	
func SetEnemyChoice(choice):
	enemy_choice = choice
	print(enemy_choice)
	
	
func on_end_game():
	if !player_win_counter == 3 or !player_loose_counter == 3:
		yield(get_tree().create_timer(1), "timeout")
		$NextRound.show()
	if player_win_counter == 3:
		hide_ui()
		$Winner.show()
		reset()
	if enemy_win_counter == 3:
		hide_ui()
		$Winner2.show()
		reset()
		
func reset():
	yield(get_tree().create_timer(5), "timeout")
	delete_points()
	player_loose_counter = 0
	player_win_counter = 0
	enemy_loose_counter = 0
	enemy_win_counter = 0
	$Start_game.show()
	$NextRound.hide()
	
func delete_points():
	var playerpoints = get_node("Control/1a/2a/Playerpoints")
	for i in playerpoints.get_children():
		playerpoints.remove_child(i)
		i.queue_free()
	var enemypoints = get_node("Control/1a/2b/Enemypoints")
	for i in enemypoints.get_children():
		playerpoints.remove_child(i)
		i.queue_free()


func _on_NextRound_pressed():
	Server.PlayerReadyGameStart()
	$GameReadyTimer.start()
	$GameReadyLabel.show()







