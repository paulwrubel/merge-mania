class_name Board
extends Node2D

const COLUMN_SCENE := preload("res://Scenes/column.tscn")
const BLOCK_SCENE := preload("res://Scenes/block.tscn")

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

const column_count: int = 5
const row_count: int = 6

const pre_block_size = 100
const pre_padding = 5
const pre_rounding_radius = 5
const pre_width = (pre_block_size * column_count) + (pre_padding * (column_count + 1))
const pre_height = (pre_block_size * row_count) + (pre_padding * (row_count + 1))

var scalar = viewport_width / pre_width

var block_size = pre_block_size * scalar
var padding = pre_padding * scalar
var width = pre_width * scalar
var height = pre_height * scalar

#position.y = viewport_height - (block_size * row_count) - (padding * 2)
#var column_height: float = viewport_height - position.y - (padding * 2)
#
#var block_size: float = (viewport_width - (padding * (column_count + 1))) / column_count

var blocks: Array[Array] = []

func get_actual_location_from_grid(grid_loc: Vector2) -> Vector2:
	return Vector2(
		padding + padding * grid_loc.x + block_size * grid_loc.x, 
		height - (padding * (grid_loc.y + 1) + block_size * (grid_loc.y + 1))
	)

func get_next_open_index_in_column(x: int) -> int:
	return blocks[x].find(null)

# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize blocks grid
	for x in range(column_count):
		var col = []
		for y in range(row_count):
			col.append(null)
		blocks.append(col)
	
	# initialize columns
	var column_x: float = padding
	for i in range(column_count):
		var column := COLUMN_SCENE.instantiate()
		column.index = i
		column.position = Vector2(column_x, padding)
		column.size = Vector2(block_size, height - padding * 2)
		column.background_color = Color.DIM_GRAY
		column.board = self
		
		add_child(column)
		
		column_x += block_size + padding
		
	position = Vector2(0, viewport_height - height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_initial_block_at(position: Vector2, val: int):
	var block = BLOCK_SCENE.instantiate()
	block.grid_position_initial = Vector2(position.x, row_count - 1)
	block.grid_position_final = position
	block.size = Vector2(block_size, block_size)
	block.board = self
	add_child(block)
	
func add_block_at(loc: Vector2, val: int):
	blocks[loc.x][loc.y] = val
