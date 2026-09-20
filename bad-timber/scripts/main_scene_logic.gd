extends Node2D

#shoot target scene and speed
@export var target_scenes: Array[PackedScene] = []
@export var move_speed: float = 150.0

#grass row positions
var row_y_cords : Array[float] = [200.0, 300.0, 400.0]
@export var grass_rows: Array[Sprite2D] = []

#all activly shootable targets in a array
var active_targets: Array[Node2D] = []

#score
var score: int = 0
@export var max_meter: float = 100.0
var current_meter: float = 50.0
@export var decay_rate: float  = 5.0

var is_game_over: bool = false

@onready var score_label = $CanvasGroup/ScoreLabel
@onready var blood_meter: TextureProgressBar = $CanvasGroup/BloodMeter
@onready var anim_player: AnimationPlayer = $CanvasGroup/AnimationPlayer
@onready var game_over_label = $CanvasGroup/WoodBoard/MarginContainer/VBoxContainer/GameOverLabel


func _ready() -> void:
	#forcing the positions of the grass rows
	for i in range (grass_rows.size()):
		if i<row_y_cords.size() and is_instance_valid(grass_rows[i]):
			grass_rows[i].position.y = row_y_cords[i]
			grass_rows[i].position.x = 0
			#establishing the render rank of each element(z_indexes)
			grass_rows[i].z_index = (i+1) * 10

	#init the UI
	update_score_ui()
	if blood_meter:
		blood_meter.max_value = max_meter
		blood_meter.value = current_meter
	
	#empty the game over label
	if game_over_label:
		game_over_label.text = ""
	
	#starts the target spawn timer
	$SpawnTargetTimer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTargetTimer.start()

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	#win-loss conditions
	if current_meter <= 0.0:
		trigger_game_over()
		return
	elif current_meter>= max_meter:
		trigger_horror_event()
		return
	
	#decay of the meter
	current_meter -= decay_rate * delta
	current_meter = clamp(current_meter, 0.0 , max_meter)
	
	#updte blood meter
	if blood_meter:
		blood_meter.value = current_meter
	
	
	#target moving logic
	for i in range(active_targets.size() -1, -1, -1):
		var target = active_targets[i]
		
		if not is_instance_valid(target):
			active_targets.remove_at(i)
			continue
		
		#direction check
		if abs(target.position.y - row_y_cords[1])<1.0:
			target.position.x -= move_speed * delta
			
			if target. position.x < -100:
				active_targets.remove_at(i)
				target.queue_free()
		else:
			target.position.x += move_speed * delta
			
			if target. position.x > get_viewport_rect().size.x +100 :
				active_targets.remove_at(i)
				target.queue_free()

func add_score(amount: int) -> void:
	
	if is_game_over:
		return
	score = max(0, score + amount)
	update_score_ui()# changing label to show score here
	
	current_meter += amount
	
	current_meter = clamp(current_meter, 0.0 , max_meter)
	
	if blood_meter:
		blood_meter.value = current_meter
	
	

func update_score_ui() -> void:
	if score_label:
		score_label.text = "Score:" + str(score)

func disable_all_target_input() -> void:
	for target in active_targets:
		if is_instance_valid(target):
			target.input_pickable = false

func play_game_over_animation() -> void:
	if game_over_label:
		game_over_label.text = "Game Over\nFinal Score: " + str(score)
	if anim_player:
		anim_player.play("game_over_reveal")

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	$SpawnTargetTimer.stop()
	
	disable_all_target_input()
	play_game_over_animation()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func trigger_horror_event() -> void:
	is_game_over = true
	$SpawnTargetTimer.stop()
	

#target spawn logic
func _on_spawn_timer_timeout() -> void:
	if target_scenes.is_empty():
		return
	
	var random_row = randi() % row_y_cords.size()
	var spawn_y = row_y_cords[random_row]
	
	var roll = randi() % 100
	var scene_index = 0
	var is_tree = false
	
	if roll<10:
		scene_index = 2
		is_tree = true
	elif roll < 30:
		scene_index = 1
	
	var new_target = target_scenes[scene_index].instantiate()
	
	#alternating row spawning
	if random_row ==1:
		new_target.position = Vector2(get_viewport_rect().size.x, spawn_y)
		new_target.flip_horizontal(true)
	else:
		new_target.position = Vector2(-50, spawn_y)
	
	#z index for tree is 3 higher than other targets on same row
	if is_tree:
		new_target.z_index = ((random_row + 1) * 10) -2
	else:
		new_target.z_index = ((random_row + 1) * 10) -5
	
	add_child(new_target)
	active_targets.append(new_target)
	
	new_target.setup_target(self)
