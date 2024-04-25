extends CanvasLayer


onready var help_label: RichTextLabel = $Panel/HelpLabel

var hovered: bool = false
var help_label_text: String = "[fill][color=#f4f1de] Scissors [/color] cuts [color=#e07a5f] paper [/color], \n" \
 + "[color=#e07a5f] paper [/color] covers [color=#30638E] rock [/color], \n" \
 + "[color=#30638E] rock [/color] crushes [color=#81b29a] lizard [/color], \n" \
 + "[color=#81b29a] lizard [/color] poisons [color=#f2cc8f] Spock [/color], \n" \
 + "[color=#f2cc8f] Spock [/color] smashes [color=#f4f1de] scissors [/color], \n" \
 + "[color=#f4f1de] scissors [/color] decapitates [color=#81b29a] lizard [/color], \n" \
 + "[color=#81b29a] lizard [/color] eats [color=#e07a5f] paper [/color], \n" \
 + "[color=#e07a5f] paper [/color] disproves [color=#f2cc8f] Spock [/color], \n" \
 + "[color=#f2cc8f] Spock [/color] vaporizes [color=#30638E] rock [/color], \n" \
 + " and as it always has, \n" \
 + "[color=#30638E] rock [/color] crushes [color=#f4f1de] scissors [fill]"

func _ready() -> void:
	help_label.bbcode_text = help_label_text


func _process(delta: float) -> void:
	if hovered:
		help_label.show()
	else:
		help_label.hide()
		


func _on_TextureRect_mouse_entered() -> void:
	print("hi")
	hovered = true


func _on_TextureRect_mouse_exited() -> void:
	hovered = false
