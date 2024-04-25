extends Node


## DEPENDENCIES ##

onready var scissors_hand_scene: PackedScene = preload("res://Hands/Scissors.tscn")
onready var lizard_hand_scene: PackedScene = preload("res://Hands/Lizard.tscn")
onready var paper_hand_scene: PackedScene = preload("res://Hands/Paper.tscn")
onready var spock_hand_scene: PackedScene = preload("res://Hands/Spock.tscn")
onready var stone_hand_scene: PackedScene = preload("res://Hands/Stone.tscn")
onready var unknown_hand_scene: PackedScene = preload("res://Hands/Unknown.tscn")
onready var confetti_particle_scene: PackedScene = preload("res://Effects/ConfettiParticles.tscn")

const SCISSORS_ICON: Texture = preload("res://assets/hands/Scissors.png")
const LIZARD_ICON: Texture = preload("res://assets/hands/Lizard.png")
const PAPER_ICON: Texture = preload("res://assets/hands/Paper.png")
const SPOCK_ICON: Texture = preload("res://assets/hands/Spok.png")
const STONE_ICON: Texture = preload("res://assets/hands/Stone.png")
const UNKNOWN_ICON: Texture =preload("res://assets/hands/Fragezeichen.png")

onready var player_hand_menu: Popup = $PlayerHandMenu
onready var waiting_for_player_label: Label = $WaitingforPlayerLabel
onready var you_win_label: Label = $YouWinLabel
onready var you_loose_label: Label = $YouLooseLabel
onready var start_game_button: Button = $StartGameButton
onready var next_round_button: Button = $NextRoundButton
onready var player_count_ready_label: Label = $PlayerCountReadyLabel
onready var player_names_hud: HBoxContainer = $PlayerNamesHUD
onready var disposables: Node = $Disposables
onready var reveal_timer: Timer = $RevealTimer
onready var post_reveal_timer: Timer = $PostRevealTimer
onready var player_1_name: Label = $PlayerNamesHUD/Player_1_Name
onready var player_2_name: Label = $PlayerNamesHUD/Player_2_Name
onready var new_game_button: Button = $NewGameButton




var current_player_choice: int
enum hands {
	SCISSORS,
	STONE,
	PAPER,
	LIZARD,
	SPOCK
}


var current_enemy_choice: int
var enemy_possibilities: Array = [
	hands.SCISSORS,
	hands.STONE,
	hands.PAPER,
	hands.LIZARD,
	hands.SPOCK,
]


var player_hand_menu_items = [
		{'texture': STONE_ICON, 'title': "Stone", 'id': hands.STONE}, 
		{'texture': SCISSORS_ICON, 'title': "Scissors", 'id': hands.SCISSORS},
		{'texture': PAPER_ICON, 'title': "Paper", 'id': hands.PAPER},
		{'texture': LIZARD_ICON, 'title': "Lizard", 'id': hands.LIZARD},
		{'texture': SPOCK_ICON, 'title': "Spock", 'id': hands.SPOCK},
	]

var player_hand_position: Vector2 = Vector2.ZERO
var enemy_hand_position: Vector2 = Vector2.ZERO

var player_win_counter: int = 0
var enemy_win_counter: int = 0

signal stalemate
signal player_wins
signal enemy_wins
signal end_game
signal names_received

func _ready() -> void:
	hide_ui()
	
	waiting_for_player_label.show()

	
	Signals.connect("player_wins", self, "_on_player_wins")
	Signals.connect("bot_wins", self, "_on_bot_wins")
	Signals.connect("draw", self, "_on_draw")
	Signals.connect("game_over", self, "_on_game_over")

	calculate_hand_positions()
	set_up_player_hand_menu()
#	connect("enemy_wins", self, "on_enemy_wins")
#	connect("stalemate", self, "on_stalemate")
#	connect("end_game", self, "on_end_game")

	Server.send_player_requester(get_instance_id())
	Server.send_player_ready_notice()



func calculate_hand_positions() -> void:
	player_hand_position = Vector2(get_viewport().size.x/4,get_viewport().size.y/2)
	enemy_hand_position = Vector2(get_viewport().size.x * 3/4,get_viewport().size.y/2)


func set_up_player_hand_menu() -> void:
	player_hand_menu.menu_items = player_hand_menu_items


func hide_ui():
	you_win_label.hide()
	you_loose_label.hide()
	next_round_button.hide()
	player_count_ready_label.hide()
	player_names_hud.hide()
	start_game_button.hide()
	new_game_button.hide()


func _on_PlayerHandMenu_item_selected(id, position) -> void:
	current_player_choice = id
	player_count_ready_label.show()
	push_current_choice_to_the_server(current_player_choice)
	#Server.send_player_ready_notice()


func start_visualization() -> void:
	player_count_ready_label.hide()
	
	instance_player_hand_scene()
	instance_enemy_hand_scene()
	reveal_timer.start()


func instance_player_hand_scene() -> void:
	var current_player_hand_scene: PackedScene = find_player_hand_scene()
	var new_hand = current_player_hand_scene.instance()
	new_hand.position = player_hand_position
	disposables.add_child(new_hand)
	new_hand.set_current_owner("PLAYER")


func instance_enemy_hand_scene() -> void:
	var new_hand: Node2D = unknown_hand_scene.instance()
	new_hand.position = enemy_hand_position
	disposables.add_child(new_hand)
	new_hand.set_current_owner("BOT")


func find_player_hand_scene() -> PackedScene:
	if current_player_choice == hands.SCISSORS:
		return scissors_hand_scene
	elif current_player_choice == hands.LIZARD:
		return lizard_hand_scene
	elif current_player_choice == hands.PAPER:
		return paper_hand_scene
	elif current_player_choice == hands.STONE:
		return stone_hand_scene
	else: 
		return spock_hand_scene


func _on_RevealTimer_timeout() -> void:
	reveal_timer.stop()
	var bot_hand_texture_info: Array = find_bot_texture()
	instance_bot_sprite(bot_hand_texture_info)
	post_reveal_timer.start()


func find_bot_texture() -> Array:
	if current_enemy_choice == hands.SCISSORS:
		return [SCISSORS_ICON, false]
	elif current_enemy_choice == hands.LIZARD:
		return [LIZARD_ICON, true]
	elif current_enemy_choice == hands.PAPER:
		return [PAPER_ICON, false]
	elif current_enemy_choice == hands.STONE:
		return [STONE_ICON, false]
	else: 
		return [SPOCK_ICON, false]


func instance_bot_sprite(bot_hand_texture_info: Array) -> void:
	var new_sprite: Sprite = Sprite.new()
	new_sprite.texture = bot_hand_texture_info[0]
	new_sprite.position = enemy_hand_position
	disposables.add_child(new_sprite)
	if !bot_hand_texture_info[1]:
		new_sprite.flip_h = true


func _on_PostRevealTimer_timeout() -> void:
	post_reveal_timer.stop()
	check_who_won()


func check_who_won() -> void:
	if current_player_choice == hands.SCISSORS:
		if current_enemy_choice == hands.SCISSORS:
			Signals.emit_signal("draw")
		elif current_enemy_choice == hands.STONE or current_enemy_choice == hands.SPOCK:
			Signals.emit_signal("bot_wins")
		elif current_enemy_choice == hands.PAPER or current_enemy_choice == hands.LIZARD:
			Signals.emit_signal("player_wins")
	
	if current_player_choice == hands.STONE:
		if current_enemy_choice == hands.SCISSORS or current_enemy_choice == hands.LIZARD:
			Signals.emit_signal("player_wins")
		elif current_enemy_choice == hands.STONE:
			Signals.emit_signal("draw")
		elif current_enemy_choice == hands.PAPER or current_enemy_choice == hands.SPOCK:
			Signals.emit_signal("bot_wins")
	
	if current_player_choice == hands.PAPER :
		if current_enemy_choice == hands.STONE or current_enemy_choice == hands.SPOCK:
			Signals.emit_signal("player_wins")
		elif current_enemy_choice == hands.SCISSORS or current_enemy_choice == hands.LIZARD:
			Signals.emit_signal("bot_wins")
		elif current_enemy_choice == hands.PAPER:
			Signals.emit_signal("draw")
	
	if current_player_choice == hands.LIZARD:
		if current_enemy_choice == hands.PAPER or current_enemy_choice == hands.SPOCK:
			Signals.emit_signal("player_wins")
		elif current_enemy_choice == hands.SCISSORS or current_enemy_choice == hands.STONE:
			Signals.emit_signal("bot_wins")
		elif current_enemy_choice == hands.LIZARD:
			Signals.emit_signal("draw")
	
	if current_player_choice == hands.SPOCK:
		if current_enemy_choice == hands.SCISSORS or current_enemy_choice == hands.STONE:
			Signals.emit_signal("player_wins")
		elif current_enemy_choice == hands.PAPER or current_enemy_choice == hands.LIZARD:
			Signals.emit_signal("bot_wins")
		elif current_enemy_choice == hands.SPOCK:
			Signals.emit_signal("draw")


func _on_player_wins() -> void:
	instance_confetti(Vector2(get_viewport().size.x/4, 0))
	player_win_counter += 1
	check_game_end_condition()


func _on_bot_wins() -> void:
	instance_confetti(Vector2(get_viewport().size.x * 3/4, 0))
	enemy_win_counter += 1
	check_game_end_condition()


func _on_draw() -> void:
	next_round_button.show()


func instance_confetti(pos: Vector2) -> void:
	var new_confetti: Particles2D = confetti_particle_scene.instance()
	new_confetti.position = pos
	disposables.add_child(new_confetti)


func check_game_end_condition() -> void:
	if player_win_counter == 3 or enemy_win_counter == 3:
		if player_win_counter == 3:
			you_win_label.show()
		else:
			you_loose_label.show()
		Server.send_game_finished_notice()
		player_win_counter = 0
		enemy_win_counter = 0
		new_game_button.show()
	else:
		next_round_button.show()


func _on_NextRoundButton_pressed() -> void:
	next_round_button.hide()
	clear_disposables()
	player_count_ready_label.show()
	Server.send_player_ready_notice()


func _on_NewGameButton_pressed() -> void:
	new_game_button.hide()
	you_win_label.hide()
	you_loose_label.hide()
	clear_disposables()
	player_count_ready_label.show()
	Signals.emit_signal("new_round_initiated")
	Server.send_player_ready_notice()


func clear_disposables() -> void:
	for child in disposables.get_children():
		child.queue_free()


func _on_StartGameButton_pressed() -> void:
	Server.send_player_ready_notice()
	player_count_ready_label.show()


################################################################################
## SERVER COMMUNICATION ##


func set_both_player_names(player_name: String, enemy_name: String) -> void:
	player_1_name.text = player_name
	player_2_name.text = enemy_name
	waiting_for_player_label.hide()
	
	start_game_button.show()


func start_game() -> void:
	player_hand_menu.open_menu(player_hand_position)
	hide_ui()


func push_current_choice_to_the_server(choice: int) -> void:
	Server.push_player_choice(choice)
	Server.send_player_ready_notice()


func set_enemy_choice(enemy_choice: int) -> void:
	current_enemy_choice = enemy_choice
	start_visualization()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		pass


#var mouse_inside_player_hand_menu: bool = false
#
#func _on_PlayerHandMenu_mouse_entered() -> void:
#	mouse_inside_player_hand_menu = true
##	player_hand_menu.set_m = MOUSE_FILTER_STOP
#
#
#func _on_PlayerHandMenu_mouse_exited() -> void:
#	mouse_inside_player_hand_menu = false
##	player_hand_menu.mouse_filter = MOUSE_FILTER_IGNORE



