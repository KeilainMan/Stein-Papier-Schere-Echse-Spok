extends Node

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

onready var point_display: CanvasLayer = $PointDisplay
onready var post_round_display: CanvasLayer = $PostRoundDisplay
onready var player_hand_menu: Popup = $PlayerHandMenu
onready var disposable: Node = $Disposable
onready var reveal_timer: Timer = $RevealTimer
onready var post_reveal_timer: Timer = $PostRevealTimer
onready var next_small_round_button: Button = $NextSmallRoundButton
onready var player_wins_label: Label = $PostRoundDisplay/HBoxContainer2/HBoxContainer/PlayerWinsLabel
onready var bot_wins_label: Label = $PostRoundDisplay/HBoxContainer2/HBoxContainer/BotWinsLabel



enum hands {
	SCISSORS,
	STONE,
	PAPER,
	LIZARD,
	SPOCK
}

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

var current_player_hand: int
var current_bot_hand: int
var player_hand_position: Vector2 = Vector2.ZERO
var bot_hand_position: Vector2 = Vector2.ZERO


func _ready():
	randomize()
	calculate_hand_positions()
	set_up_player_hand_menu()

	Signals.connect("player_wins", self, "_on_player_wins")
	Signals.connect("bot_wins", self, "_on_bot_wins")
	Signals.connect("stalemate", self, "_on_stalemate")
	Signals.connect("game_over", self, "_on_game_over")

	start_new_small_round()


func calculate_hand_positions() -> void:
	player_hand_position = Vector2(get_viewport().size.x/4,get_viewport().size.y/2)
	bot_hand_position = Vector2(get_viewport().size.x * 3/4,get_viewport().size.y/2)


func set_up_player_hand_menu() -> void:
	player_hand_menu.menu_items = player_hand_menu_items


func start_new_small_round() -> void:
	post_round_display.hide()
	clear_disposables()
	player_hand_menu.open_menu(player_hand_position)


func _on_PlayerHandMenu_item_selected(id, position):
	current_player_hand = id
	roll_bot_hand()
	begin_visual_comparison_process()


func roll_bot_hand() -> void:
	enemy_possibilities.shuffle()
	current_bot_hand = enemy_possibilities[0]
	print("bot: ", current_bot_hand, "player: ", current_player_hand)


func begin_visual_comparison_process() -> void:
	instance_player_hand_scene()
	instance_bot_hand_scene()
	reveal_timer.start()


func instance_player_hand_scene() -> void:
	var current_player_hand_scene: PackedScene = find_player_hand_scene()
	var new_hand = current_player_hand_scene.instance()
	new_hand.position = player_hand_position
	disposable.add_child(new_hand)
	new_hand.set_current_owner("PLAYER")


func instance_bot_hand_scene() -> void:
	var new_hand: Node2D = unknown_hand_scene.instance()
	new_hand.position = bot_hand_position
	disposable.add_child(new_hand)
	new_hand.set_current_owner("BOT")


func find_player_hand_scene() -> PackedScene:
	if current_player_hand == hands.SCISSORS:
		return scissors_hand_scene
	elif current_player_hand == hands.LIZARD:
		return lizard_hand_scene
	elif current_player_hand == hands.PAPER:
		return paper_hand_scene
	elif current_player_hand == hands.STONE:
		return stone_hand_scene
	else: 
		return spock_hand_scene


func _on_revealtimer_timeout() -> void:
	var bot_hand_texture_info: Array = find_bot_texture()
	instance_bot_sprite(bot_hand_texture_info)
	post_reveal_timer.start()


func find_bot_texture() -> Array:
	if current_bot_hand == hands.SCISSORS:
		return [SCISSORS_ICON, false]
	elif current_bot_hand == hands.LIZARD:
		return [LIZARD_ICON, true]
	elif current_bot_hand == hands.PAPER:
		return [PAPER_ICON, false]
	elif current_bot_hand == hands.STONE:
		return [STONE_ICON, false]
	else: 
		return [SPOCK_ICON, false]


func instance_bot_sprite(bot_hand_texture_info: Array) -> void:
	var new_sprite: Sprite = Sprite.new()
	new_sprite.texture = bot_hand_texture_info[0]
	new_sprite.position = bot_hand_position
	disposable.add_child(new_sprite)
	if !bot_hand_texture_info[1]:
		new_sprite.flip_h = true


func _on_PostRevealTimer_timeout() -> void:
	check_who_won()


func check_who_won() -> void:
	if current_player_hand == hands.SCISSORS:
		if current_bot_hand == hands.SCISSORS:
			Signals.emit_signal("stalemate")
		elif current_bot_hand == hands.STONE or current_bot_hand == hands.SPOCK:
			Signals.emit_signal("bot_wins")
		elif current_bot_hand == hands.PAPER or current_bot_hand == hands.LIZARD:
			Signals.emit_signal("player_wins")
	
	if current_player_hand == hands.STONE:
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.LIZARD:
			Signals.emit_signal("player_wins")
		elif current_bot_hand == hands.STONE:
			Signals.emit_signal("stalemate")
		elif current_bot_hand == hands.PAPER or current_bot_hand == hands.SPOCK:
			Signals.emit_signal("bot_wins")
	
	if current_player_hand == hands.PAPER :
		if current_bot_hand == hands.STONE or current_bot_hand == hands.SPOCK:
			Signals.emit_signal("player_wins")
		elif current_bot_hand == hands.SCISSORS or current_bot_hand == hands.LIZARD:
			Signals.emit_signal("bot_wins")
		elif current_bot_hand == hands.PAPER:
			Signals.emit_signal("stalemate")
	
	if current_player_hand == hands.LIZARD:
		if current_bot_hand == hands.PAPER or current_bot_hand == hands.SPOCK:
			Signals.emit_signal("player_wins")
		elif current_bot_hand == hands.SCISSORS or current_bot_hand == hands.STONE:
			Signals.emit_signal("bot_wins")
		elif current_bot_hand == hands.LIZARD:
			Signals.emit_signal("stalemate")
	
	if current_player_hand == hands.SPOCK:
		if current_bot_hand == hands.SCISSORS or current_bot_hand == hands.STONE:
			Signals.emit_signal("player_wins")
		elif current_bot_hand == hands.PAPER or current_bot_hand == hands.LIZARD:
			Signals.emit_signal("bot_wins")
		elif current_bot_hand == hands.SPOCK:
			Signals.emit_signal("stalemate")


func _on_player_wins() -> void:
	instance_confetti(Vector2(get_viewport().size.x/4, 0))
	next_small_round_button.show()


func _on_bot_wins() -> void:
	instance_confetti(Vector2(get_viewport().size.x * 3/4, 0))
	next_small_round_button.show()


func _on_stalemate() -> void:
	next_small_round_button.show()


func instance_confetti(pos: Vector2) -> void:
	var new_confetti: Particles2D = confetti_particle_scene.instance()
	new_confetti.position = pos
	disposable.add_child(new_confetti)


func _on_NextSmallRoundButton_pressed() -> void:
	next_small_round_button.hide()
	start_new_small_round()


func _on_game_over(winner: String) -> void:
	if winner == "PLAYER":
		bot_wins_label.hide()
	else:
		player_wins_label.hide()
	post_round_display.show()
	next_small_round_button.hide()


func _on_NextRoundButton_pressed() -> void:
	Signals.emit_signal("new_round_initiated")
	start_new_small_round()


func clear_disposables() -> void:
	for child in disposable.get_children():
		child.queue_free()
