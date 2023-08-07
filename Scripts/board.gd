class_name Board
extends Node2D

const COLUMN_SCENE := preload("res://Scenes/column.tscn")

@export var column_count: int = 5
@export var column_padding: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var column_width: float = (viewport_width - (column_padding * (column_count + 1))) / column_count
	
	var column_x: float = column_padding
	for i in range(column_count):
		var column := COLUMN_SCENE.instantiate()
		column.position = Vector2(column_x, column_padding)
		column.size = Vector2(column_width, 200)
		column.background_color = Color.DIM_GRAY
		
		add_child(column)
		
		column_x += column_width + column_padding

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
