class_name Board
extends Node2D

const COLUMN_SCENE := preload("res://Scenes/column.tscn")

@export var column_count: int = 5
@export var row_count: int = 6

@export var padding: int = 5

var blocks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(column_count):
		var col = []
		for y in range(row_count):
			col.append(0)
		blocks.append(col)
			
	
	var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	var column_width: float = (viewport_width - (padding * (column_count + 1))) / column_count
	position.y = viewport_height - (column_width * row_count) - (padding * 2)
	var column_height: float = viewport_height - position.y - (padding * 2)
	
	
	var column_x: float = padding
	for i in range(column_count):
		var column := COLUMN_SCENE.instantiate()
		column.index = i
		column.position = Vector2(column_x, padding)
		column.size = Vector2(column_width, column_height)
		column.background_color = Color.DIM_GRAY
		column.board = self
		
		add_child(column)
		
		column_x += column_width + padding

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func add_block_at(loc: Vector2, val: int):
	blocks[loc.x][loc.y] = val
