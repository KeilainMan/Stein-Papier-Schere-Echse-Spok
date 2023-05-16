extends GridContainer


onready var schere = get_node("ASchere")
onready var stein = get_node("AStein")
onready var papier = get_node("APapier")
onready var echse = get_node("AEchse")
onready var spok = get_node("ASpok")




func _ready():
	schere.set_texture(load("res://Scissors.png"))
	stein.set_texture(load("res://Stone.png"))
	papier.set_texture(load("res://Paper.png"))
	echse.set_texture(load("res://Lizard.png"))
	spok.set_texture(load("res://Spok.png"))
	echse.set_flip_h(true)
	var vec = Vector2(0.5,0.5)
	schere.set_scale(vec)
	stein.set_scale(vec)
	papier.set_scale(vec)
	echse.set_scale(vec)
	spok.set_scale(vec)
	set_scale(vec)
