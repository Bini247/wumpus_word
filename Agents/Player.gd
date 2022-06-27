extends KinematicBody2D

onready var ray = $RayCast2D
onready var grid = get_parent()

export(String, FILE) var win_scene: = ""
export(String, FILE) var died_scene: = ""

var tried_positions = []

var gold_found = false
var is_dead = false

var steps = 0
var points = 0

var is_ia_mode = GameData.is_ia_mode

var grid_size = 32
var inputs = {
	'ui_up': Vector2.UP,
	'ui_down': Vector2.DOWN,
	'ui_left': Vector2.LEFT,
	'ui_right': Vector2.RIGHT
}

var inputs_array = [
	'ui_up',
	'ui_down',
	'ui_left',
	'ui_right'
]

var trap_positions = []
var wumpus_positions = []

var type_positions = {
	"wumpus": false,
	"traps": false
}

var is_close_to_trap = false
var is_close_to_wumpus = false

var wait_message = false

func _ready():
	$MainTheme.play()
	
	$CanvasLayer/UserInterface/VBoxContainer/Points.text = "Points: " + str(points)
	$CanvasLayer/UserInterface/VBoxContainer/Steps.text = "Steps: " + str(steps)
	$CanvasLayer/UserInterface/VBoxContainer/Situation.text = ""
	randomize()
	tried_positions.append(Vector2(1,6))
	if is_ia_mode:
		yield(get_tree().create_timer(1.0), 'timeout') 
		pathFind()

func _unhandled_input(event):
	if is_ia_mode: return 
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func is_colliding(vector_pos):
	ray.cast_to = vector_pos
	ray.force_raycast_update()
	
	if ray.is_colliding(): return true
	
	var next_position = grid.world_to_map(vector_pos+position)
	
	if !is_ia_mode: return false
		
	if next_position in tried_positions: return true
	
	if next_position in trap_positions && type_positions.get('traps'): return true
	
	if next_position in wumpus_positions && type_positions.get('wumpus'): return true
	
func move(dir):
	var vector_pos = inputs[dir] * grid_size
	if is_colliding(vector_pos) || wait_message: return false
	
	position += vector_pos
	var coordinates = grid.world_to_map(position)
	steps += 1
	$CanvasLayer/UserInterface/VBoxContainer/Steps.text = "Steps: " + str(steps)
	
	if coordinates == Vector2(1,6) && gold_found: 
		get_tree().change_scene(win_scene)
		
	return true

func ia_move():
	if is_close_to_trap: 
		if choose_close_to_enemy_path(is_close_to_trap): return true
	
	if is_close_to_wumpus:
		if choose_close_to_enemy_path(is_close_to_wumpus): return true
		
	var vector_pos = Vector2.UP * grid_size
	if set_next_position(vector_pos): return true
	
	vector_pos = Vector2.RIGHT * grid_size
	if set_next_position(vector_pos): return true
	
	vector_pos = Vector2.DOWN * grid_size
	if set_next_position(vector_pos): return true
	
	vector_pos = Vector2.LEFT * grid_size
	if set_next_position(vector_pos): return true
	
	tried_positions.remove(len(tried_positions)-2)
	return false

func choose_close_to_enemy_path(close_to_enemy):
	inputs_array.shuffle()
	for input in inputs_array:
		var vector_pos = inputs[input] * grid_size
		if !is_colliding(vector_pos):
			position += vector_pos
			var coordinates = grid.world_to_map(position)
			tried_positions.append(coordinates)
			close_to_enemy = false
			return true
			
func set_next_position(vector_pos):
	if !is_colliding(vector_pos): 
		position += vector_pos
		var coordinates = grid.world_to_map(position)
		tried_positions.append(coordinates)
		return true
		
func pathFind():
	var max_tiles = 1000
	while max_tiles > 0 && !gold_found:
		yield(get_tree().create_timer(1.0), 'timeout')
		
		if wait_message: yield(get_tree().create_timer(2.0), 'timeout')
		
		var can_move = false
		while !can_move && !gold_found:
			if ia_move(): can_move = true
		steps += 1
		$CanvasLayer/UserInterface/VBoxContainer/Steps.text = "Steps: " + str(steps)
		max_tiles -= 1

func _on_Area2D_body_entered(body):
	if !"type" in body: return
	
	if body.type == 'gold':
		$MainTheme.stop()
		$GoldTheme.play()
		body.set_open()
		points += 100
		$CanvasLayer/UserInterface/VBoxContainer/Points.text = "Points: " + str(points)
		gold_found = true
		
		if !is_ia_mode: return
		
		var arrayinv = tried_positions.duplicate()
		arrayinv.invert()
		for current_position in arrayinv:
			yield(get_tree().create_timer(1.0), 'timeout')
			position = current_position * grid_size
			steps +=1
			$CanvasLayer/UserInterface/VBoxContainer/Steps.text = "Steps: " + str(steps)
		get_tree().change_scene(win_scene)
	if body.type == 'trap':
		is_dead = true
		get_tree().change_scene(died_scene)
	if body.type == 'wumpus':
		is_dead = true
		get_tree().change_scene(died_scene)

func _on_Area2D_area_entered(area):
	if gold_found || !("type" in area): return
	
	if area.type == 'gold':
		wait_message = true
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(225,223,0,1)
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = "You see the gold's shine"
		yield(get_tree().create_timer(3.0), 'timeout')
		wait_message = false
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = ""
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(0,0,0,1)
		return
		
	if area.type == 'trap':
		is_close_to_trap = true
		wait_message = true
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(153,101,21,1)
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = "You hear a trap's noise"
		$Trap.play()
		yield(get_tree().create_timer(3.0), 'timeout')
		$Trap.stop()
		wait_message = false
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = ""
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(0,0,0,1)
		set_enemies_positions('traps', trap_positions)
		return 
		
	if area.type == 'wumpus':
		is_close_to_wumpus = true
		wait_message = true
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(0,100,0,1)
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = "You smell the wumpus's stink"
		$Wumpus.play()
		yield(get_tree().create_timer(3.0), 'timeout')
		$Wumpus.stop()
		wait_message = false
		$CanvasLayer/UserInterface/VBoxContainer/Situation.text = ""
		$CanvasLayer/UserInterface/VBoxContainer/Situation.self_modulate = Color(0,0,0,1)
		set_enemies_positions('wumpus', wumpus_positions)
		return

func set_enemies_positions(type_name, enemy_position):
	if type_positions.get(type_name): return
	
	var vector_pos = Vector2.UP * grid_size
	var new_position = position + vector_pos
	if check_if_is_enemy_position(new_position, enemy_position, type_name): return true
	
	vector_pos = Vector2.RIGHT * grid_size
	new_position = position + vector_pos
	if check_if_is_enemy_position(new_position, enemy_position, type_name): return true
	
	vector_pos = Vector2.DOWN * grid_size
	new_position = position + vector_pos
	if check_if_is_enemy_position(new_position, enemy_position, type_name): return true
	
	vector_pos = Vector2.LEFT * grid_size
	new_position = position + vector_pos
	if check_if_is_enemy_position(new_position, enemy_position, type_name): return true
		
func check_if_is_enemy_position(new_position, enemy_position, type_name):
	if !(new_position) in tried_positions: 
		if grid.world_to_map(new_position) in enemy_position: 
			type_positions[type_name] = true
			enemy_position = grid.world_to_map(new_position)
			return true
		enemy_position.append(grid.world_to_map(new_position))
