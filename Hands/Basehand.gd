extends Node2D
class_name BaseHand

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

var current_owner: String = "PLAYER" setget set_current_owner
var current_animation: String = "LeftShake"

func _ready() -> void:
	animation_player.play(current_animation)


func toggle_sprite_flip() -> void:
	if sprite.flip_h:
		sprite.flip_h = false
	else:
		sprite.flip_h = true


func set_current_owner(new_owner: String) -> void:
	current_owner = new_owner
	if current_owner == "PLAYER":
		current_animation = "LeftShake"
	else:
		current_animation = "RightShake"
		toggle_sprite_flip()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "RightShake":
		queue_free()
