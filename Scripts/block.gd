class_name Block
extends Node2D

var board: Board

var grid_position_initial: Vector2i
var grid_position_final: Vector2i
var size := Vector2(100, 100)
var background_color := Color.GREEN
var value: int

const ROUNDED_CORNER_SIZE = 10

func initialize(settings: Dictionary):
	grid_position_initial = settings.grid_position_initial
	grid_position_final = settings.grid_position_final
	size = settings.size
	board = settings.board
	value = settings.value

# Called when the node enters the scene tree for the first time.
func _ready():
	position = board.get_actual_location_from_grid(grid_position_initial)
	
	var actual_location_to_anim_to = board.get_actual_location_from_grid(grid_position_final)
	var tween = create_tween()
	tween.tween_property(self, "position", actual_location_to_anim_to, 0.2) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func(): anim_callback(grid_position_final, value))
	
	$BlockLabel.size = size
	($BlockLabel.label_settings as LabelSettings).font_size = 48
	$BlockLabel.text = str(value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
			
func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = background_color
	
	draw_style_box(style_box, Rect2(Vector2(0, 0), size))
	
func anim_callback(final_pos: Vector2i, val: int):
	board.add_block_at(final_pos, val)
	board.advance_block_progression()
	board.anim_lock = false
