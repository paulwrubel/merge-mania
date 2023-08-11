class_name Block
extends Node2D

var board: Board

var location: Vector2
var size := Vector2(100, 100)
var background_color := Color.GREEN
var toggled_color := Color.BLUE
var is_toggled := false

const ROUNDED_CORNER_SIZE = 10
const LOCAL_POSITION = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y + 450), 1) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	var add_block = func():
		board.add_block_at(location, 1)
	tween.tween_callback(add_block)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
	
#func _input_event(viewport: Viewport, event: InputEvent, shape_index: int):
#	if event is InputEventMouseButton:
#		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
#			# spawn a block
#			BLOCK_SCENE.instantiate()
			
func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = toggled_color if is_toggled else background_color
	
	draw_style_box(style_box, Rect2(LOCAL_POSITION, size))
