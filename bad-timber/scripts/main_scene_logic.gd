extends Node2D

#shoot target scene and speed
@export var target_scene: PackedScene
@export var move_speed: float = 150.0

#grass row positions
var row_y_cords : Array[float] = [200.0, 300.0, 400.0]
@export var grass_rows: Array[Sprite2D] = []

#all activly shootable targets in a array
var active_targets: Array[Node2D] = []

#score
var score: int = 0
@onready var score_label = $CanvasGroup/ScoreLabel

func _ready() -> void:
	#init the scorelabel
	update_score_ui()
	#forcing the positions of the grass rows
	for i in range (grass_rows.size()):
		if i<row_y_cords.size() and is_instance_valid(grass_rows[i]):
			grass_rows[i].position.y = row_y_cords[i]
			grass_rows[i].position.x = 0
			#establishing the render rank of each element(z_indexes)
			grass_rows[i].z_index = (i+1) * 10
	
	#starts the target spawn timer
	$SpawnTarget_Timer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTarget_Timer.start()

func _process(delta: float) -> void:
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

func add_score(amount: int) -> void:
	score+= amount
	update_score_ui()
	# changing label to show score here

func update_score_ui() -> void:
	if score_label:
		score_label.text = "Score:" + str(score)

#target spawn logic
func _on_spawn_timer_timeout() -> void:
	if target_scene == null:
		return
	
	var random_row = randi() % row_y_cords.size()
	var spawn_y = row_y_cords[random_row]
	
	var new_target = target_scene.instantiate()
	
	#alternating row spawning
	if random_row ==1:
		new_target.position = Vector2(get_viewport_rect().size.x, spawn_y)
		new_target.flip_horizontal(true)
	else:
		new_target.position = Vector2(-50, spawn_y)
	
	#target type
	var roll = randi() % 100
	var target_type = "bunny"
	
	if roll<10:
		target_type = "tree"
	elif roll < 30:
		target_type = "deer"
	
	#z index for tree is 3 higher than other targets on same row
	if target_type == "tree":
		new_target.z_index = ((random_row + 1) * 10) -2
	else:
		new_target.z_index = ((random_row + 1) * 10) -5
	
	add_child(new_target)
	active_targets.append(new_target)
	
	new_target.setup_target(target_type, self)
