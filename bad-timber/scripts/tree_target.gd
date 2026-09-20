extends Area2D

@export var points: int = 1

var main_scene : Node2D = null
var is_hit: bool = false

func setup_target(main_ref: Node2D) -> void:
	main_scene = main_ref
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# is there a mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_hit:
			_on_clicked()
			
func _on_clicked() -> void:
	is_hit = true
	$CollisionShape2D.set_deferred("disabled", true)
	
	if is_instance_valid(main_scene):
		main_scene.add_score(points)
	
	queue_free()

func flip_horizontal(should_flip: bool) -> void:
	$Sprite2D.flip_h = should_flip
