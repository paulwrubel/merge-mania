class_name Block
extends Node2D

var _board: Board

var size: Vector2
var color: Color
var data: BlockData

const ROUNDED_CORNER_SIZE = 10
const DEFAULT_FONT_SIZE = 40


func setup(
	board_: Board,
	position_: Vector2,
	size_: Vector2,
	scale_: Vector2,
	data_: BlockData,
):
	_board = board_

	position = position_
	size = size_
	data = data_
	scale = scale_


# Called when the node enters the scene tree for the first time.
func _ready():
	var BlockUtils = $"/root/BlockUtils"

	var font = $BlockLabel.label_settings.font

	color = BlockUtils.get_block_background_color(data)

	var text = BlockUtils.get_formatted_block_text(data)
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, DEFAULT_FONT_SIZE)
	var font_size_scalar = (size.x / text_size.x) * 0.95

	var font_color = ColorUtils.get_highest_contrast_to(color, [Color.BLACK, Color.WHITE])
	LabelSettings.new()
	var label_settings = LabelSettings.new()
	label_settings.font = font
	label_settings.font_size = (
		DEFAULT_FONT_SIZE if font_size_scalar >= 1.0 else DEFAULT_FONT_SIZE * font_size_scalar
	)
	label_settings.font_color = font_color
	$BlockLabel.label_settings = label_settings
	$BlockLabel.size = size
	$BlockLabel.text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()


func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = color

	draw_style_box(style_box, Rect2(Vector2(0, 0), size))
