extends Area2D

@export var bunny_texture : Texture2D
@export var deer_texture : Texture2D

var main_scene : Node2D = null

var is_hit: bool = false
var is_deer: bool = false
var points: int = 1

@onready var sprite = $Sprite2D

func setup_target(type_is_deer: bool, main_ref: Node2D) -> void:
	is_deer = type_is_deer
	main_scene = main_ref
	
	if is_deer:
		points = 3
		if deer_texture:
			sprite.texture = deer_texture
		else:
			points = 1
			if bunny_texture:
				sprite.texture = bunny_texture

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# is there a mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_clicked()

func _on_clicked() -> void:
	is_hit = true
	$CollisionShape2D.set_deferred("disabled", true)
	
	if is_instance_valid(main_scene):
		main_scene.add_score(points)
	
	queue_free()
