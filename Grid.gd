extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var OBSTACLE

var grid_size = Vector2(8,8)
var grid = []

var inputs = [
	'ui_up',
	'ui_down',
	'ui_left',
	'ui_right'
]

var candles_angles = {
	'top': {
		'x': half_tile_size.x*2,
		'y':half_tile_size.y,
		'angle': 0
	},
	'left': {
		'x': half_tile_size.x,
		'y':half_tile_size.y*2,
		'angle': -90
	},
	'bottom': {
		'x': half_tile_size.x*2,
		'y':half_tile_size.y,
		'angle': 180
	},
	'right': {
		'x': half_tile_size.x,
		'y':half_tile_size.y*2,
		'angle': 90
	}
}

onready var Gold = preload("res://Agents/Gold.tscn")
onready var Wumpus = preload("res://Agents/Wumpus.tscn")
onready var Trap = preload("res://Agents/Trap.tscn")
onready var Candle = preload("res://Agents/Candle.tscn")

var object_dictionary

onready var AlertArea = preload("res://Agents/AlertArea.tscn")

func _ready():
	object_dictionary = {
		'gold': Gold,
		'wumpus': Wumpus,
		'trap': Trap,
	}
	randomize()
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			set_cell(x, y, 1)
			grid[x].append(null)
	
	var positions = []
	
	set_tile_positions(positions)
	
	var player_position = Vector2(1,6)
	
	set_object_position(positions, player_position, 'gold')
	
	set_object_position(positions, player_position, 'wumpus')
	
	for n in range(2):
		set_object_position(positions, player_position, 'trap')

func set_tile_positions(positions):
	for n in range(grid_size.x):
		var grid_pos = Vector2(n, 0)
		if not grid_pos in positions:
			set_cell(n, 0, 0)
			if n == 0: set_cell(n, 0, 2)
			if n == ((grid_size.x / 2) -1): set_calndles_positions(grid_pos, 'top')
			positions.append(grid_pos)
		grid_pos = Vector2(0, n)
		if not grid_pos in positions:
			set_cell(0, n, 4)
			if n == ((grid_size.x / 2) -1): set_calndles_positions(grid_pos, 'left')
			positions.append(grid_pos)
		grid_pos = Vector2(n, grid_size.x-1)
		if not grid_pos in positions:
			set_cell(n, grid_size.x-1, 6)
			if n == 0: set_cell(n, grid_size.x-1, 7)
			if n == grid_size.x-1: set_cell(n, grid_size.x-1, 8)
			if n == ((grid_size.x / 2) -1): set_calndles_positions(grid_pos, 'bottom')
			positions.append(grid_pos)
		grid_pos = Vector2(grid_size.x-1, n)
		if not grid_pos in positions:
			set_cell(grid_size.x-1, n, 5)
			if n == 0: set_cell(grid_size.x-1, 0, 3)
			if n == ((grid_size.x / 2) -1): set_calndles_positions(grid_pos, 'right')
			positions.append(grid_pos)

func set_calndles_positions(grid_pos, map_side):
	#if GameData.is_ia_mode: return
	
	var new_object = Candle.instance()
	grid_pos = map_to_world(grid_pos)
	
	grid_pos.x = grid_pos.x + candles_angles[map_side].x
	grid_pos.y = grid_pos.y + candles_angles[map_side].y
	
	new_object.rotation_degrees = candles_angles[map_side].angle
	new_object.position = grid_pos
	add_child(new_object)

func set_object_position(positions, player_position, object_type):
	var object_position = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))
	while object_position in positions || (object_position.x - player_position.x < 2 && object_position.y - player_position.y < 2):
		object_position = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))
	var new_object = object_dictionary[object_type].instance()
	new_object.position = (map_to_world(object_position) + half_tile_size)
	grid[object_position.x][object_position.y] = OBSTACLE
	add_child(new_object)
	positions.append(object_position)
	
	set_alert_area_position(object_position, object_type, map_to_world(Vector2(object_position.x + 1, object_position.y)))
	set_alert_area_position(object_position, object_type, map_to_world(Vector2(object_position.x, object_position.y + 1)))
	set_alert_area_position(object_position, object_type, map_to_world(Vector2(object_position.x - 1, object_position.y)))
	set_alert_area_position(object_position, object_type, map_to_world(Vector2(object_position.x, object_position.y - 1)))

func set_alert_area_position(parent_position, type, new_position):
	var new_area = AlertArea.instance()
	new_area.type = type
	new_area.position = (new_position + half_tile_size)
	add_child(new_area)
	
