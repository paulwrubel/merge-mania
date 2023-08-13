class_name Column
extends Area2D

const BLOCK_SCENE := preload("res://Scenes/block.tscn")

var board: Board

var index: int
var size := Vector2(100, 200)
var background_color := Color.DIM_GRAY
var toggled_color := Color.RED
var is_toggled := false

const ROUNDED_CORNER_SIZE = 10
const LOCAL_POSITION = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape.size = size
	$CollisionShape2D.position = size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
	
func _input_event(viewport: Viewport, event: InputEvent, shape_index: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			board.try_spawn_initial_block_in(index)
			
func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = toggled_color if is_toggled else background_color
	
	draw_style_box(style_box, Rect2(LOCAL_POSITION, size))
	
