extends Area2D

@export var points: int = 1
@export var score_popup_scene: PackedScene

var main_scene : Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func setup_target(main_ref: Node2D) -> void:
	main_scene = main_ref
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# is there a mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_top_target_at_mouse():
			take_hit()
			
func is_top_target_at_mouse() -> bool:
	var world_2d= get_world_2d()
	if not world_2d:
		return true
	var space_state = world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results = space_state.intersect_point(query)
	var highest_z:int = -9999
	var top_area: Area2D = null
	
	for result in results:
		var area = result.get("collider") as Area2D
		if is_instance_valid(area) and area.z_index > highest_z:
			highest_z = area.z_index
			top_area = area
	if top_area == self:
		get_viewport().set_input_as_handled()
		return true
	return false

func take_hit() -> void:
	if is_instance_valid(main_scene):
		main_scene.add_score(points)
	
	spawn_score_popup(str(points), Color.RED)
	play_impact_shake()

func spawn_score_popup(text:String, text_color: Color) -> void:
	if score_popup_scene:
		var popup = score_popup_scene.instantiate()
		
		popup.global_position = global_position + Vector2(-100, -185)
		popup.z_index  = 300
	
		if is_instance_valid(main_scene):
			main_scene.add_child(popup)
		else: get_parent().add_child(popup)
		popup.setup(text, text_color)

func play_impact_shake() -> void:
	var tween = create_tween()
	tween.tween_property(sprite,"rotation_degrees", 5, 0.04 )
	tween.tween_property(sprite,"rotation_degrees", -5, 0.04 )
	tween.tween_property(sprite,"rotation_degrees", 0, 0.04 )

func flip_horizontal(should_flip: bool) -> void:
	$Sprite2D.flip_h = should_flip
