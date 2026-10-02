extends Node2D

@onready var label: Label = $Label
var font = load("res://resources/Chango-Regular.ttf")

func setup(text_value:String, color: Color ) -> void:
	if not is_node_ready():
		await ready
	
	label.text = text_value
	label.add_theme_font_override("font",font)
	label.add_theme_color_override("font_color",color)
	label.add_theme_font_size_override("font_size", 40)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y" , position.y - 10.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
