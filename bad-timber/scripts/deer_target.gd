extends Area2D

@export var points: int = 1
@export var score_popup_scene: PackedScene

var main_scene : Node2D = null
var is_hit: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func setup_target(main_ref: Node2D) -> void:
	main_scene = main_ref
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# is there a mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_hit:
			_on_clicked()
			
func _on_clicked() -> void:
	is_hit = true
	collision_shape.set_deferred("disabled", true)
	
	if is_instance_valid(main_scene):
		main_scene.add_score(points)
	
	spawn_score_popup("+" + str(points), Color.GREEN)
	
	play_knockdown_animation()

func spawn_score_popup(text:String, text_color: Color) -> void:
	if score_popup_scene:
		var popup = score_popup_scene.instantiate()
		
		popup.global_position = global_position + Vector2(-100, -145)
		popup.z_index  = 300
	
		if is_instance_valid(main_scene):
			main_scene.add_child(popup)
		else: get_parent().add_child(popup)
		popup.setup(text, text_color)

func play_knockdown_animation() -> void:
	var shake_tween = create_tween()
	
	var target_y:float = global_position.y +128
	shake_tween.tween_property(sprite,"rotation_degrees", 5, 0.04 )
	shake_tween.tween_property(sprite,"rotation_degrees", -5, 0.04 )
	shake_tween.tween_property(sprite,"rotation_degrees", 0, 0.04 )
	
	await shake_tween.finished
	
	var fall_tween = create_tween().set_parallel(true)
	
	fall_tween.tween_property(self, "global_position:y", target_y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_tween.tween_property(self, "scale:y" , 0.1, 0.4)
	
	await fall_tween.finished
	
	if is_instance_valid(main_scene) and main_scene.active_targets.has(self):
		main_scene.active_targets.erase(self)
		
	queue_free()

func flip_horizontal(should_flip: bool) -> void:
	$Sprite2D.flip_h = should_flip
