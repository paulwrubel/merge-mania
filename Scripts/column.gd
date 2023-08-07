class_name Column
extends Node2D

var size := Vector2(100, 200)
var background_color = Color.DIM_GRAY

const ROUNDED_CORNER_SIZE = 10
const LOCAL_POSITION = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
	pass

func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = background_color
	
	draw_style_box(style_box, Rect2(LOCAL_POSITION, size))
	
