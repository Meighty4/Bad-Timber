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
var is_horror_phase : bool = false
var waiting_for_targets_clear: bool = false

var deformed_deer: Node2D = null
var rotten_tree: Node2D = null
var deer_current_row: int = 0
var deer_timer: float = 0.0
var tree_hit_count: int = 0

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
	
	if not is_horror_phase and not waiting_for_targets_clear:
		#win-loss conditions
		if current_meter <= 0.0:
			trigger_game_over()
			return
		elif current_meter>= max_meter:
			trigger_horror_event_start()
			return
		
		#decay of the meter
		current_meter -= decay_rate * delta
		current_meter = clamp(current_meter, 0.0 , max_meter)
	
		#updte blood meter
		if blood_meter:
			blood_meter.value = current_meter
	
	if waiting_for_targets_clear:
		clean_active_targets()
		if active_targets.is_empty():
			waiting_for_targets_clear = false
			start_horror_event()
		else:
			move_normal_targets(delta)
		return
	if is_horror_phase:
		process_horror_event(delta)
		return
	move_normal_targets(delta)

func clean_active_targets() -> void:
	for i in range(active_targets.size() -1, -1, -1):
		if not is_instance_valid(active_targets[i]):
			active_targets.remove_at(i)
	
func move_normal_targets(delta: float) -> void:
	for i in range(active_targets.size() -1, -1, -1):
		var target = active_targets[i]
		if not is_instance_valid(target):
			active_targets.remove_at(i)
			continue
			
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

func trigger_horror_event_start() -> void:
	$SpawnTargetTimer.stop()
	waiting_for_targets_clear = true

func start_horror_event() -> void:
	is_horror_phase = true 
	deer_current_row = 0
	deer_timer = 0.0
	tree_hit_count = 0
	
	spawn_deformed_deer()
	spawn_deformed_tree()

func spawn_deformed_deer() -> void:
	if target_scenes.size() >3 and target_scenes[3] != null:
		deformed_deer = target_scenes[3].instantiate()#change later to scene of s_deer as curently its normal deer
		deformed_deer.position = Vector2(800, row_y_cords[0])
		deformed_deer.z_index= (0 + 1) * 10 - 5 # 0 is index of row
		add_child(deformed_deer)
		
		if deformed_deer.has_method("setup_target"):
			deformed_deer.setup_target(self)

func spawn_deformed_tree() -> void:
	if target_scenes.size() >4 and target_scenes[4] != null:
		rotten_tree = target_scenes[4].instantiate()#change later to scene of s_tree as curently its normal tree
		rotten_tree.position = Vector2(400, row_y_cords[2])
		rotten_tree.z_index= (2 + 1) * 10 - 5 # 2 is index of row
		add_child(rotten_tree)
		
		if rotten_tree.has_method("setup_target"):
			rotten_tree.setup_target(self)

func process_horror_event(delta: float) -> void:
	if not is_instance_valid(deformed_deer):
		return
	
	deer_timer += delta
	if deer_timer >= 3.0:
		deer_timer = 0.0
		deer_current_row +=1
		
		if deer_current_row < row_y_cords.size():
			deformed_deer.position.y = row_y_cords[deer_current_row]
			deformed_deer.z_index = (deer_current_row + 1) *10 -5
		elif deer_current_row == 3:
			trigger_jumpscare()

func hit_rotten_tree() -> void:
	if not is_horror_phase:
		return
	tree_hit_count += 1
	if tree_hit_count == 1:
		if is_instance_valid(rotten_tree):
			rotten_tree.rotation_degrees = 45.0
	elif tree_hit_count >=2:
		if is_instance_valid(rotten_tree):
			rotten_tree.rotation_degrees = 90.0
		trigger_win_sequence()

func trigger_win_sequence() -> void:
	is_horror_phase = false
	is_game_over = true
	
	if is_instance_valid(deformed_deer):
		deformed_deer.queue_free()
	
	play_game_over_animation("...")
	
func trigger_jumpscare() -> void:
	is_horror_phase = false
	is_game_over = true
	
	if is_instance_valid(deformed_deer):
		deformed_deer.position = Vector2(450,600)
		deformed_deer.scale = Vector2(4.0 , 4.0)
		deformed_deer.z_index = 130
		
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

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

func play_game_over_animation(text: String) -> void:
	if game_over_label:
		game_over_label.text = text + "\nFinal Score: " + str(score)
	if anim_player:
		anim_player.play("game_over_reveal")

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	$SpawnTargetTimer.stop()
	
	disable_all_target_input()
	play_game_over_animation("Game Over")

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


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
