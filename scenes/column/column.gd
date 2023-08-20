class_name Column
extends Area2D

var board: Board

var index: int
var size := Vector2(100, 200)
var background_color := Color.html("#222222")
var hover_color := Color.html("#333333")
var is_hovering := false

const ROUNDED_CORNER_SIZE = 10
const LOCAL_POSITION = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	$CollisionShape2D.shape.size = size
	$CollisionShape2D.position = size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_index: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			board.try_spawn_initial_block_in(index)


func _on_mouse_entered():
	is_hovering = true


func _on_mouse_exited():
	is_hovering = false

	
func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	var color = hover_color if is_hovering else background_color
	style_box.bg_color = color
	
	draw_style_box(style_box, Rect2(LOCAL_POSITION, size))
