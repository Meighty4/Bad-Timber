extends Area2D

@export var points: int = 1

var main_scene : Node2D = null
#var is_hit: bool = false

func setup_target(main_ref: Node2D) -> void:
	main_scene = main_ref
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# is there a mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_instance_valid(main_scene):
			main_scene.hit_rotten_tree()
