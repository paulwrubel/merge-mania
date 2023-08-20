class_name Block
extends Node2D

# var _board: Board

var size: Vector2 = Vector2(100, 100)
var color: Color
var data: BlockData = PowerBlockData.new(1)

const ROUNDED_CORNER_SIZE = 10
const DEFAULT_FONT_SIZE = 40


func setup(
	position_: Vector2,
	size_: Vector2,
	scale_: Vector2,
	data_: BlockData,
):
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

	var contrast_color = color if data.type == BlockData.Type.POWER else Color.WHITE
	var font_color = ColorUtils.get_highest_contrast_to(contrast_color, [Color.BLACK, Color.WHITE])
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
# func _process(_delta):
# 	queue_redraw()


func _draw():
	match data.type:
		BlockData.Type.POWER:
			_draw_power_block()
		BlockData.Type.WILDCARD:
			_draw_wildcard_block()


func _draw_power_block():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	style_box.bg_color = color

	draw_style_box(style_box, Rect2(Vector2(0, 0), size))


func _draw_wildcard_block():
	# draw the colorful outline
	var outer_style_box = StyleBoxFlat.new()
	outer_style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE)
	outer_style_box.bg_color = color
	var outer_rect = Rect2(
		Vector2(0, 0),
		size,
	)
	draw_style_box(outer_style_box, outer_rect)

	# draw the white inner box
	var wildcard_inner_scalar = 0.8
	var inner_style_box = StyleBoxFlat.new()
	inner_style_box.set_corner_radius_all(ROUNDED_CORNER_SIZE * wildcard_inner_scalar)
	inner_style_box.bg_color = Color.WHITE
	var inner_style_box_size = size * wildcard_inner_scalar
	var inner_rect = Rect2(
		(size - inner_style_box_size) / 2,
		inner_style_box_size,
	)
	draw_style_box(inner_style_box, inner_rect)


	# draw the triangles
	var triangle_height_vector = Vector2(0, 0.1 * size.y)
	var triangle_width_vector = Vector2(0.1 * size.x, 0)
	var dirs: Array = [
		WildcardBlockData.CardinalDirection.NORTH,
		WildcardBlockData.CardinalDirection.EAST,
		WildcardBlockData.CardinalDirection.SOUTH,
		WildcardBlockData.CardinalDirection.WEST,
	]
	print(data.directions)
	for i in dirs.size():
		var dir = dirs[i]
		print("checking for {0}".format([dir]))
		draw_set_transform(size / 2, i * (PI / 2))
		if (data as WildcardBlockData).directions.has(dir):
			print("drawing {0}".format([dir]))
			var a = Vector2(0, -size.x * 0.4)
			var b = a - (triangle_width_vector / 2) + triangle_height_vector
			var c = b + triangle_width_vector
			draw_colored_polygon([a, b, c], Color.BLACK)
	draw_set_transform(Vector2(0, 0), 0)
