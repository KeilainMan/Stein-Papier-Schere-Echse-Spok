extends Node2D
class_name BaseHand

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite


func _ready() -> void:
	animation_player.play("Shake")
