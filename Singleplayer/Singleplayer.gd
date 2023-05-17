extends Node

onready var scissors_hand_scene: PackedScene = preload("res://Hands/Scissors.tscn")
onready var lizard_hand_scene: PackedScene = preload("res://Hands/Lizard.tscn")
onready var paper_hand_scene: PackedScene = preload("res://Hands/Paper.tscn")
onready var spock_hand_scene: PackedScene = preload("res://Hands/Spok.tscn")
onready var stone_hand_scene: PackedScene = preload("res://Hands/Stone.tscn")

enum hands {
	SCISSORS,
	STONE,
	PAPER,
	LIZARD,
	SPOK
}

var enemy_possibilities: Array = [
	hands.SCISSORS,
	hands.STONE,
	hands.PAPER,
	hands.LIZARD,
	hands.SPOK,
]

var current_player_hand: int
var current_bot_hand: int
var player_win_counter: int = 0
var enemy_loose_counter: int = 0
var enemy_win_counter: int = 0
var player_loose_counter: int = 0

onready var a_player_1 = get_node("AnimationPlayer")
onready var a_player_2 = get_node("AnimationPlayer2")

signal stalemate
signal player_wins
signal enemy_wins
signal end_game

func _ready():
	hide_ui()
	$player_selection.hide()
	connect("player_wins", self, "on_player_wins")
	connect("enemy_wins", self, "on_enemy_wins")
	connect("stalemate", self, "on_stalemate")
	connect("end_game", self, "on_end_game")
	
	var new_hand = scissors_hand_scene.instance()
	new_hand.position = get_viewport().size/2
	add_child(new_hand)


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

	
func winner_determination():
	if current_player_hand == hands.SCISSORS:
		if current_bot_hand == hands.SCISSORS:
			emit_signal("stalemate") 
			print("Stalemate")
		if current_bot_hand == hands.STONE or current_bot_hand == hands.SPOK:
			emit_signal("enemy_wins")
			print("enemy wins")
		if current_bot_hand == hands.PAPER or current_bot_hand == hands.LIZARD:
			emit_signal("player_wins")
			print("player wins")
	if current_player_hand == hands.STONE:
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.LIZARD:
			emit_signal("player_wins")
		if current_bot_hand == hands.STONE:
			emit_signal("stalemate")
		if current_bot_hand == hands.PAPER or current_bot_hand == hands.SPOK:
			emit_signal("enemy_wins")
	if current_player_hand == hands.PAPER :
		if current_bot_hand == hands.STONE or current_bot_hand == hands.SPOK:
			emit_signal("player_wins")
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.LIZARD:
			emit_signal("enemy_wins")
		if current_bot_hand == hands.PAPER:
			emit_signal("stalemate")
	if current_player_hand == hands.LIZARD:
		if current_bot_hand == hands.PAPER or current_bot_hand == hands.SPOK:
			emit_signal("player_wins")
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.STONE:
			emit_signal("enemy_wins")
		if current_bot_hand == hands.LIZARD:
			emit_signal("stalemate")
	if current_player_hand == hands.SPOK:
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.STONE:
			emit_signal("player_wins")
		if current_bot_hand == hands.PAPER or current_bot_hand == hands.LIZARD:
			emit_signal("enemy_wins")
		if current_bot_hand == hands.SPOK:
			emit_signal("stalemate")
			



func _on_ASchere_pressed():
	current_player_hand = hands.SCISSORS
	start_after_selection()

func _on_AStein_pressed():
	current_player_hand = hands.STONE
	start_after_selection()

func _on_APapier_pressed():
	current_player_hand = hands.PAPER
	start_after_selection()

func _on_AEchse_pressed():
	current_player_hand = hands.LIZARD
	start_after_selection()

func _on_ASpok_pressed():
	current_player_hand = hands.SPOK
	start_after_selection()

func start_after_selection():
	$player_selection.hide()
	$Revealtimer.start()
	$Hbox/Cntr1/Fragezeichen1.show()
	$Hbox/Cntr2/Fragezeichen2.show()

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
	enemy_choice_selection()
	
func enemy_choice_selection():
	enemy_possibilities.shuffle()
	current_bot_hand = enemy_possibilities[0]
	show_enemy_choice()
	
func show_player_selection():
	if current_player_hand == hands.SCISSORS:
		$Hbox/Cntr1/Schere.show()
		#animation rammen
	if current_player_hand == hands.STONE:
		$Hbox/Cntr1/Stein.show()
		#animation rammen
	if current_player_hand == hands.PAPER:
		$Hbox/Cntr1/Papier.show()
		#animation rammen
	if current_player_hand == hands.LIZARD:
		$Hbox/Cntr1/Echse.show()
		#animation rammen
	if current_player_hand == hands.SPOK:
		$Hbox/Cntr1/Spok.show()
		#animation rammen
		
func show_enemy_choice():
	if current_bot_hand == hands.SCISSORS:
		$Hbox/Cntr2/ESchere.show()
		#animation rammen
		winner_determination()
	if current_bot_hand == hands.STONE:
		$Hbox/Cntr2/EStein.show()
		#animation rammen
		winner_determination()
	if current_bot_hand == hands.PAPER:
		$Hbox/Cntr2/EPapier.show()
		#animation rammen
		winner_determination()
	if current_bot_hand == hands.LIZARD:
		$Hbox/Cntr2/EEchse.show()
		#animation rammen
		winner_determination()
	if current_bot_hand == hands.SPOK:
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
	point.set_texture(load("res://assets/score/won_point.png"))
	position.add_child(point, player_win_counter)
	player_win_counter += 1
	emit_signal("end_game")
	
func add_loose_enemy():
	var position = get_node("Control/1a/2b/Enemypoints")
	var point = TextureRect.new()
	point.set_texture(load("res://assets/score/lost_point.png"))
	position.add_child(point, enemy_loose_counter)
	enemy_loose_counter += 1
	
func on_enemy_wins():
	yield(get_tree().create_timer(1), "timeout")
	add_player_loose()
	add_enemy_win()

	

func add_player_loose():
	var position = get_node("Control/1a/2a/Playerpoints")
	var point = TextureRect.new()
	point.set_texture(load("res://assets/score/lost_point.png"))
	position.add_child(point, player_loose_counter)
	player_loose_counter += 1
	
func add_enemy_win():
	var position = get_node("Control/1a/2b/Enemypoints")
	var point = TextureRect.new()
	point.set_texture(load("res://assets/score/won_point.png"))
	position.add_child(point, enemy_win_counter)
	enemy_win_counter += 1
	emit_signal("end_game")
	
func on_stalemate():
	$NextRound.show()


func _on_Start_game_pressed():
	$player_selection.show()
	hide_ui()
	$Start_game.hide()

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
	$player_selection.show()
	hide_ui()
	$NextRound.hide()
