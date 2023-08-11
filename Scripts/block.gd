class_name Block
extends Node2D

var board: Board

var grid_position_initial: Vector2
var grid_position_final: Vector2
var size := Vector2(100, 100)
var background_color := Color.GREEN
var toggled_color := Color.BLUE
var is_toggled := false

const ROUNDED_CORNER_SIZE = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	position = board.get_actual_location_from_grid(grid_position_initial)
	
	var actual_location_to_anim_to = board.get_actual_location_from_grid(grid_position_final)
	
	var tween = create_tween()
	tween.tween_property(self, "position", actual_location_to_anim_to, 1) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func(): board.add_block_at(grid_position_final, 1))

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
	
	draw_style_box(style_box, Rect2(position, size))
