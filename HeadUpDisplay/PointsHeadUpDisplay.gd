extends Control

onready var loose_point: Texture = preload("res://assets/score/lost_point.png")
onready var win_point: Texture = preload("res://assets/score/won_point.png")
onready var stalemate_point: Texture = preload("res://assets/score/Neutral_point.png")

onready var playerpoints = $VBoxContainer/HBoxContainer/Playerpoints
onready var enemypoints = $VBoxContainer/HBoxContainer/Enemypoints

var bot_win_counter: int = 0
var player_win_counter: int = 0


func _ready():
	Signals.connect("player_wins", self, "_on_player_wins")
	Signals.connect("bot_wins", self, "_on_bot_wins")
	Signals.connect("draw", self, "_on_draw")
	Signals.connect("new_round_initiated", self, "_on_new_round_initiated")
	
	
func _on_player_wins() -> void:
	instance_new_point(win_point, true)
	instance_new_point(loose_point, false)
	player_win_counter += 1
	if player_win_counter >=3:
		Signals.emit_signal("game_over", "PLAYER")


func _on_bot_wins() -> void:
	instance_new_point(loose_point, true)
	instance_new_point(win_point, false)
	bot_win_counter += 1
	if bot_win_counter >=3:
		Signals.emit_signal("game_over", "BOT")


func _on_draw() -> void:
	instance_new_point(stalemate_point, true)
	instance_new_point(stalemate_point, false)


func instance_new_point(point_texture: Texture, is_player: bool) -> void:
	var point = TextureRect.new()
	point.set_texture(point_texture)
	if is_player:
		playerpoints.add_child(point)
	else:
		enemypoints.add_child(point)


func _on_new_round_initiated() -> void:
	clear_points()
	clear_scores()


func clear_points() -> void:
	for child in playerpoints.get_children():
		child.queue_free()
	for child in enemypoints.get_children():
		child.queue_free()


func clear_scores() -> void:
	bot_win_counter = 0
	player_win_counter = 0
